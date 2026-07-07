const { getChatContext, setChatContext } = require("./redisCache.service");
const pool = require("../config/db");

async function getChatMessages(chatId) {
  const cachedMessages = await getChatContext(chatId);

  if (cachedMessages) {
    console.log("Chat context loaded from Redis");
    return cachedMessages;
  }

  const result = await pool.query(
    "SELECT * FROM messages WHERE chat_id = $1 ORDER BY created_at ASC",
    [chatId]
  );

  await setChatContext(chatId, result.rows);

  console.log("Chat context loaded from PostgreSQL and saved to Redis");
  return result.rows;
}

module.exports = {
  getChatMessages,
};