# Redis Cache Strategy

Redis is used for fast temporary data in Aura AI.

---

## Responsibilities

Redis handles:

- sessions
- chat context cache
- memory retrieval cache
- rate limiting
- temporary AI context
- WebSocket state
- frequently accessed data

---

## Key Naming Convention

| Purpose | Key Pattern |
|---|---|
| Session | `session:{user_id}:{device_id}` |
| WebSocket State | `ws:{user_id}` |
| Chat Context | `chat_context:{chat_id}` |
| Memory Cache | `memory_cache:{user_id}:{query_hash}` |
| Rate Limit | `rate_limit:{user_id}:{route}:{minute}` |
| Temporary AI Context | `ai_temp:{chat_id}` |
| Frequently Accessed Data | `frequent:{key_name}` |

---

## TTL Plan

| Data | TTL |
|---|---|
| Session | 7 days |
| WebSocket state | 1 hour |
| Chat context | 30 to 60 minutes |
| Memory cache | 10 to 30 minutes |
| Rate limit | 60 seconds |
| Temporary AI context | 10 minutes |
| Frequently accessed data | 5 to 30 minutes |

---

## Chat Context Flow

```text
User opens chat
   ↓
Backend checks Redis chat_context:{chat_id}
   ↓
If found, return cached data
   ↓
If not found, fetch PostgreSQL messages
   ↓
Save result in Redis
```

---

## Memory Cache Flow

```text
User asks question
   ↓
FastAPI checks memory_cache:{user_id}:{query_hash}
   ↓
If hit, use cached memory
   ↓
If miss, search ChromaDB
   ↓
Save result in Redis
```

---

## Rate Limiting Flow

```text
Request received
   ↓
Redis increments rate_limit key
   ↓
If count exceeds limit, block request
   ↓
Key expires after 60 seconds
```

---

## WebSocket State Flow

```text
User connects
   ↓
Save socket ID in Redis
   ↓
User disconnects
   ↓
Update user state
```

---

## Redis CLI Test

```bash
docker exec -it aura_redis redis-cli
PING
KEYS *
TTL key_name
```

Expected:

```text
PONG
```
