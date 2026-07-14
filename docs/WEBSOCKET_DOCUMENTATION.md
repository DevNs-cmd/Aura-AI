# WebSocket Documentation

This document explains the WebSocket flow for Aura AI.

---

## Ownership

WebSocket should be handled by the NestJS backend gateway.

```text
Flutter App
   ↓
NestJS WebSocket Gateway
   ↓
FastAPI AI Service when AI response is required
   ↓
Redis for socket state and cache
```

---

## Purpose

WebSocket is used for:

- real-time chat
- typing indicators
- streaming AI response tokens
- online/offline state
- chat room events
- connection state management

---

## Redis WebSocket State

Key pattern:

```text
ws:{user_id}
```

Example:

```text
Key: ws:user_123

socket_id: abc123
status: online
last_seen: 1783350000000
```

---

## Client Events

| Event | Purpose |
|---|---|
| `chat:join` | Join a chat room |
| `chat:send` | Send chat message |
| `typing:start` | User started typing |
| `typing:stop` | User stopped typing |
| `disconnect` | User disconnected |

---

## Server Events

| Event | Purpose |
|---|---|
| `chat:joined` | Chat room joined |
| `chat:start` | AI response started |
| `chat:token` | Partial AI token |
| `chat:done` | AI response complete |
| `chat:error` | Chat error |
| `typing:start` | Other user typing |
| `typing:stop` | Other user stopped typing |

---

## Chat Join Payload

```json
{
  "chatId": "chat_uuid"
}
```

---

## Chat Send Payload

```json
{
  "chatId": "chat_uuid",
  "message": "Hello Aura"
}
```

---

## Token Stream Payload

```json
{
  "chatId": "chat_uuid",
  "token": "partial response token"
}
```

---

## WebSocket Flow

```text
User opens chat
   ↓
Flutter connects to NestJS WebSocket gateway
   ↓
NestJS validates JWT
   ↓
Socket ID saved in Redis
   ↓
User sends chat message
   ↓
NestJS forwards AI task to FastAPI
   ↓
FastAPI generates response
   ↓
NestJS emits response/token to Flutter
   ↓
Chat saved in PostgreSQL
```

---

## Production Notes

- use `wss://` in production
- validate JWT during socket connection
- apply rate limiting
- store socket state in Redis
- do not expose internal FastAPI WebSocket directly to Flutter unless approved
- ensure CORS and WebSocket origin policy are configured
