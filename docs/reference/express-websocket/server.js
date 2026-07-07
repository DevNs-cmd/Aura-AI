const express = require("express");
const http = require("http");
const cors = require("cors");
require("dotenv").config({ path: "../.env" });

const { Server } = require("socket.io");

const rateLimit = require("./middleware/rateLimit.middleware");
const cacheTestRoutes = require("./routes/cacheTest.routes");
const registerChatSocket = require("./websocket/chat.socket");

const app = express();

app.use(cors({
  origin: process.env.FRONTEND_ORIGIN || "*",
  credentials: true,
}));

app.use(express.json());

// HTTP rate limits
app.use("/chat", rateLimit({ limit: 30, windowSeconds: 60 }));
app.use("/auth/login", rateLimit({ limit: 5, windowSeconds: 60 }));

// Redis test routes
app.use(
  "/api/cache-test",
  rateLimit({ limit: 20, windowSeconds: 60 }),
  cacheTestRoutes
);

app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "Aura AI Node backend is running",
  });
});

app.get("/health", (req, res) => {
  res.json({
    success: true,
    service: "Aura AI Node Backend",
    websocket: "enabled",
  });
});

// Create HTTP server
const server = http.createServer(app);

// Create Socket.IO server
const io = new Server(server, {
  cors: {
    origin: process.env.FRONTEND_ORIGIN || "*",
    methods: ["GET", "POST"],
    credentials: true,
  },
  transports: ["websocket", "polling"],
});

// Register WebSocket logic
registerChatSocket(io);

const PORT = process.env.NODE_PORT || 5000;

server.listen(PORT, () => {
  console.log(`Node backend running on port ${PORT}`);
  console.log(`WebSocket server running on ws://localhost:${PORT}`);
});