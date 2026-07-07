const crypto = require("crypto");
const redis = require("../config/redis");

const TTL = {
  SESSION: 7 * 24 * 60 * 60,
  WS_STATE: 60 * 60,
  CHAT_CONTEXT: 60 * 60,
  MEMORY_CACHE: 30 * 60,
  RATE_LIMIT: 60,
  AI_TEMP: 10 * 60,
  FREQUENT: 15 * 60,
};

function hashQuery(query) {
  return crypto.createHash("sha256").update(query).digest("hex");
}

// 1. Session Management
async function setSession(userId, deviceId, refreshToken) {
  const key = `session:${userId}:${deviceId}`;
  await redis.set(key, refreshToken, "EX", TTL.SESSION);
  return key;
}

async function getSession(userId, deviceId) {
  const key = `session:${userId}:${deviceId}`;
  return await redis.get(key);
}

async function deleteSession(userId, deviceId) {
  const key = `session:${userId}:${deviceId}`;
  await redis.del(key);
  return key;
}

// 2. WebSocket State Management
async function setWebSocketState(userId, socketId) {
  const key = `ws:${userId}`;

  await redis.hset(key, {
    socket_id: socketId,
    status: "online",
    last_seen: Date.now().toString(),
  });

  await redis.expire(key, TTL.WS_STATE);

  return key;
}

async function removeWebSocketState(userId) {
  const key = `ws:${userId}`;

  await redis.hset(key, {
    status: "offline",
    last_seen: Date.now().toString(),
  });

  await redis.expire(key, TTL.WS_STATE);

  return key;
}

async function getWebSocketState(userId) {
  const key = `ws:${userId}`;
  return await redis.hgetall(key);
}

// 3. Chat Context Caching
async function setChatContext(chatId, messages) {
  const key = `chat_context:${chatId}`;
  await redis.set(key, JSON.stringify(messages), "EX", TTL.CHAT_CONTEXT);
  return key;
}

async function getChatContext(chatId) {
  const key = `chat_context:${chatId}`;
  const data = await redis.get(key);
  return data ? JSON.parse(data) : null;
}

async function deleteChatContext(chatId) {
  const key = `chat_context:${chatId}`;
  await redis.del(key);
  return key;
}

// 4. Memory Retrieval Caching
async function setMemoryCache(userId, query, memories) {
  const queryHash = hashQuery(query);
  const key = `memory_cache:${userId}:${queryHash}`;

  await redis.set(key, JSON.stringify(memories), "EX", TTL.MEMORY_CACHE);

  return key;
}

async function getMemoryCache(userId, query) {
  const queryHash = hashQuery(query);
  const key = `memory_cache:${userId}:${queryHash}`;

  const data = await redis.get(key);
  return data ? JSON.parse(data) : null;
}

// 5. Temporary AI Context
async function setTemporaryAIContext(chatId, context) {
  const key = `ai_temp:${chatId}`;
  await redis.set(key, JSON.stringify(context), "EX", TTL.AI_TEMP);
  return key;
}

async function getTemporaryAIContext(chatId) {
  const key = `ai_temp:${chatId}`;
  const data = await redis.get(key);
  return data ? JSON.parse(data) : null;
}

async function deleteTemporaryAIContext(chatId) {
  const key = `ai_temp:${chatId}`;
  await redis.del(key);
  return key;
}

// 6. Frequently Accessed Data Caching
async function setFrequentlyAccessedData(keyName, data) {
  const key = `frequent:${keyName}`;
  await redis.set(key, JSON.stringify(data), "EX", TTL.FREQUENT);
  return key;
}

async function getFrequentlyAccessedData(keyName) {
  const key = `frequent:${keyName}`;
  const data = await redis.get(key);
  return data ? JSON.parse(data) : null;
}

module.exports = {
  setSession,
  getSession,
  deleteSession,

  setWebSocketState,
  removeWebSocketState,
  getWebSocketState,

  setChatContext,
  getChatContext,
  deleteChatContext,

  setMemoryCache,
  getMemoryCache,

  setTemporaryAIContext,
  getTemporaryAIContext,
  deleteTemporaryAIContext,

  setFrequentlyAccessedData,
  getFrequentlyAccessedData,
};