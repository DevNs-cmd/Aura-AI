const { io } = require("socket.io-client");

const socket = io("http://localhost:5000", {
  transports: ["websocket"],
  auth: {
    userId: "user_123",
  },
});

socket.on("connect", () => {
  console.log("Connected:", socket.id);
});

socket.on("ws:connected", (data) => {
  console.log("WS Connected:", data);

  socket.emit("chat:join", {
    chatId: "chat_123",
  });

  socket.emit("chat:send", {
    chatId: "chat_123",
    message: "Hello Aura, explain my database setup.",
  });
});

socket.on("chat:joined", (data) => {
  console.log("Chat Joined:", data);
});

socket.on("chat:start", (data) => {
  console.log("Chat Started:", data);
});

socket.on("chat:token", (data) => {
  process.stdout.write(data.token);
});

socket.on("chat:done", (data) => {
  console.log("\n\nChat Done:", data);
  socket.disconnect();
});

socket.on("chat:error", (error) => {
  console.error("Chat Error:", error);
});

socket.on("disconnect", () => {
  console.log("Disconnected");
});