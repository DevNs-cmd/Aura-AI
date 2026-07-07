const jwt = require("jsonwebtoken");

const redis = require("../config/redis");
const pool = require("../config/db");

const {
  setWebSocketState,
  removeWebSocketState,
  getChatContext,
  setChatContext,
  setTemporaryAIContext,
  deleteTemporaryAIContext,
} = require("../services/redisCache.service");

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || "http://127.0.0.1:8000";

function isUuid(value) {
  const uuidRegex =
    /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

  return uuidRegex.test(value);
}

function authenticateSocket(socket) {
  const token = socket.handshake.auth?.token;
  const fallbackUserId = socket.handshake.auth?.userId;

  // Production: use JWT
  if (token) {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || "aura_dev_secret");
    return decoded.id || decoded.user_id || decoded.userId;
  }

  // Development testing: allow userId directly
  if (fallbackUserId) {
    return fallbackUserId;
  }

  throw new Error("Unauthorized socket connection");
}

function getCurrentMinute() {
  return Math.floor(Date.now() / 60000);
}

async function checkSocketRateLimit(userId, limit = 30) {
  const minute = getCurrentMinute();
  const key = `rate_limit:${userId}:ws_chat:${minute}`;

  const count = await redis.incr(key);

  if (count === 1) {
    await redis.expire(key, 60);
  }

  return {
    allowed: count <= limit,
    count,
    key,
  };
}

async function saveMessage(chatId, role, content) {
  // Your PostgreSQL schema uses UUID.
  // During testing, non-UUID chat ids like "chat_123" will skip DB save.
  if (!isUuid(chatId)) {
    console.log(`Skipping PostgreSQL save because chatId is not UUID: ${chatId}`);

    return null;
  }

  const result = await pool.query(
    `INSERT INTO messages (chat_id, role, content)
     VALUES ($1, $2, $3)
     RETURNING *`,
    [chatId, role, content]
  );

  return result.rows[0];
}

async function getChatMessages(chatId) {
  const cachedMessages = await getChatContext(chatId);

  if (cachedMessages) {
    console.log("Chat context loaded from Redis");
    return cachedMessages;
  }

  if (!isUuid(chatId)) {
    console.log(`Skipping PostgreSQL fetch because chatId is not UUID: ${chatId}`);
    return [];
  }

  const result = await pool.query(
    `SELECT id, chat_id, role, content, created_at
     FROM messages
     WHERE chat_id = $1
     ORDER BY created_at ASC`,
    [chatId]
  );

  await setChatContext(chatId, result.rows);

  console.log("Chat context loaded from PostgreSQL and cached in Redis");
  return result.rows;
}

async function updateChatContextCache(chatId, userMessage, assistantMessage) {
  const existingContext = await getChatContext(chatId);
  const context = existingContext || [];

  context.push({
    role: "user",
    content: userMessage,
    created_at: new Date().toISOString(),
  });

  context.push({
    role: "assistant",
    content: assistantMessage,
    created_at: new Date().toISOString(),
  });

  // Keep only last 20 messages in Redis
  const recentContext = context.slice(-20);

  await setChatContext(chatId, recentContext);

  return recentContext;
}

async function callFastAPIStream({ userId, chatId, message, chatContext, socket }) {
  const response = await fetch(`${AI_SERVICE_URL}/ai/chat/stream`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      user_id: userId,
      chat_id: chatId,
      message,
      chat_context: chatContext,
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`FastAPI error: ${response.status} ${errorText}`);
  }

  let fullResponse = "";

  // Stream chunks from FastAPI to Flutter
  const reader = response.body.getReader();
  const decoder = new TextDecoder("utf-8");

  while (true) {
    const { done, value } = await reader.read();

    if (done) {
      break;
    }

    const chunk = decoder.decode(value, { stream: true });

    fullResponse += chunk;

    socket.emit("chat:token", {
      chatId,
      token: chunk,
    });
  }

  return fullResponse;
}

function registerChatSocket(io) {
  io.use(async (socket, next) => {
    try {
      const userId = authenticateSocket(socket);

      socket.userId = userId;

      next();
    } catch (error) {
      console.error("Socket authentication failed:", error.message);
      next(new Error("Unauthorized"));
    }
  });

  io.on("connection", async (socket) => {
    const userId = socket.userId;

    console.log(`User connected through WebSocket: ${userId}`);
    console.log(`Socket ID: ${socket.id}`);

    await setWebSocketState(userId, socket.id);

    socket.join(`user:${userId}`);

    socket.emit("ws:connected", {
      success: true,
      userId,
      socketId: socket.id,
      message: "Connected to Aura AI WebSocket",
    });

    socket.on("chat:join", async (payload, callback) => {
      try {
        const { chatId } = payload;

        if (!chatId) {
          throw new Error("chatId is required");
        }

        socket.join(`chat:${chatId}`);

        const chatContext = await getChatMessages(chatId);

        socket.emit("chat:joined", {
          success: true,
          chatId,
          cachedMessages: chatContext,
        });

        if (callback) {
          callback({
            success: true,
            chatId,
          });
        }
      } catch (error) {
        console.error("chat:join error:", error);

        socket.emit("chat:error", {
          success: false,
          message: error.message,
        });

        if (callback) {
          callback({
            success: false,
            message: error.message,
          });
        }
      }
    });

    socket.on("chat:send", async (payload, callback) => {
      const startedAt = Date.now();

      try {
        const { chatId, message } = payload;

        if (!chatId) {
          throw new Error("chatId is required");
        }

        if (!message || !message.trim()) {
          throw new Error("message is required");
        }

        const rateLimitStatus = await checkSocketRateLimit(userId, 30);

        if (!rateLimitStatus.allowed) {
          socket.emit("chat:error", {
            success: false,
            type: "rate_limit",
            message: "Too many WebSocket chat messages. Please try again later.",
          });

          if (callback) {
            callback({
              success: false,
              type: "rate_limit",
            });
          }

          return;
        }

        socket.join(`chat:${chatId}`);

        socket.emit("chat:start", {
          success: true,
          chatId,
          message: "Aura is thinking...",
        });

        // Save user message in PostgreSQL
        await saveMessage(chatId, "user", message);

        // Load recent chat context from Redis/PostgreSQL
        const chatContext = await getChatMessages(chatId);

        // Store temporary AI context in Redis
        await setTemporaryAIContext(chatId, {
          user_id: userId,
          chat_id: chatId,
          message,
          context_count: chatContext.length,
          started_at: new Date().toISOString(),
        });

        // Stream response from FastAPI
        const assistantResponse = await callFastAPIStream({
          userId,
          chatId,
          message,
          chatContext,
          socket,
        });

        // Save assistant response in PostgreSQL
        await saveMessage(chatId, "assistant", assistantResponse);

        // Update Redis chat context cache
        await updateChatContextCache(chatId, message, assistantResponse);

        // Delete temporary AI context
        await deleteTemporaryAIContext(chatId);

        const durationMs = Date.now() - startedAt;

        socket.emit("chat:done", {
          success: true,
          chatId,
          response: assistantResponse,
          durationMs,
        });

        if (callback) {
          callback({
            success: true,
            chatId,
            response: assistantResponse,
            durationMs,
          });
        }
      } catch (error) {
        console.error("chat:send error:", error);

        socket.emit("chat:error", {
          success: false,
          message: error.message,
        });

        if (callback) {
          callback({
            success: false,
            message: error.message,
          });
        }
      }
    });

    socket.on("typing:start", (payload) => {
      const { chatId } = payload;

      socket.to(`chat:${chatId}`).emit("typing:start", {
        userId,
        chatId,
      });
    });

    socket.on("typing:stop", (payload) => {
      const { chatId } = payload;

      socket.to(`chat:${chatId}`).emit("typing:stop", {
        userId,
        chatId,
      });
    });

    socket.on("disconnect", async (reason) => {
      console.log(`User disconnected: ${userId}`);
      console.log(`Reason: ${reason}`);

      await removeWebSocketState(userId);
    });
  });
}

module.exports = registerChatSocket;