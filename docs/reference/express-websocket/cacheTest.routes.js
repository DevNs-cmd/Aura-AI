const express = require("express");
const router = express.Router();

const {
  setSession,
  getSession,
  setWebSocketState,
  getWebSocketState,
  setChatContext,
  getChatContext,
  setMemoryCache,
  getMemoryCache,
  setTemporaryAIContext,
  getTemporaryAIContext,
  setFrequentlyAccessedData,
  getFrequentlyAccessedData,
} = require("../services/redisCache.service");

const { getChatMessages } = require("../services/chatContext.service");

router.post("/session", async (req, res) => {
  const { userId, deviceId, refreshToken } = req.body;

  const key = await setSession(userId, deviceId, refreshToken);
  const value = await getSession(userId, deviceId);

  res.json({
    success: true,
    key,
    value,
  });
});

router.post("/ws", async (req, res) => {
  const { userId, socketId } = req.body;

  const key = await setWebSocketState(userId, socketId);
  const value = await getWebSocketState(userId);

  res.json({
    success: true,
    key,
    value,
  });
});

router.post("/chat-context", async (req, res) => {
  const { chatId, messages } = req.body;

  const key = await setChatContext(chatId, messages);
  const value = await getChatContext(chatId);

  res.json({
    success: true,
    key,
    value,
  });
});

router.post("/memory-cache", async (req, res) => {
  const { userId, query, memories } = req.body;

  const key = await setMemoryCache(userId, query, memories);
  const value = await getMemoryCache(userId, query);

  res.json({
    success: true,
    key,
    value,
  });
});

router.post("/ai-temp", async (req, res) => {
  const { chatId, context } = req.body;

  const key = await setTemporaryAIContext(chatId, context);
  const value = await getTemporaryAIContext(chatId);

  res.json({
    success: true,
    key,
    value,
  });
});

router.post("/frequent", async (req, res) => {
  const { keyName, data } = req.body;

  const key = await setFrequentlyAccessedData(keyName, data);
  const value = await getFrequentlyAccessedData(keyName);

  res.json({
    success: true,
    key,
    value,
  });
});

router.get("/chat-messages/:chatId", async (req, res) => {
  try {
    const { chatId } = req.params;

    const messages = await getChatMessages(chatId);

    res.json({
      success: true,
      source: "Redis if cached, PostgreSQL if not cached",
      messages,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

module.exports = router;