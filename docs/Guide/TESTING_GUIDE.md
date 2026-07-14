# Testing Guide

This document defines the testing checklist before deployment.

---

## Local Infrastructure Test

Start services:

```bash
docker compose up -d
```

Check containers:

```bash
docker ps
```

Expected containers:

```text
aura_postgres
aura_redis
aura_chromadb
```

---

## PostgreSQL Test

Open PostgreSQL:

```bash
docker exec -it aura_postgres psql -U aura_user -d aura_ai
```

List tables:

```sql
\dt
```

Expected tables:

```text
users
chats
messages
memories
documents
journal_entries
```

---

## Redis Test

```bash
docker exec -it aura_redis redis-cli
PING
```

Expected response:

```text
PONG
```

Test key:

```bash
SET test_key "Aura Redis Working"
GET test_key
```

---

## ChromaDB Test

Run FastAPI:

```bash
python -m uvicorn app.main:app --reload --port 8000
```

Open:

```text
http://127.0.0.1:8000/docs
```

Test:

```text
GET /health/chroma
```

---

## NestJS Backend Test

Install dependencies:

```bash
npm install
```

Run backend:

```bash
npm run start:dev
```

Check health route if available:

```http
GET /health
```

---

## FastAPI AI Service Test

Run:

```bash
python -m uvicorn app.main:app --reload --port 8000
```

Open Swagger:

```text
http://127.0.0.1:8000/docs
```

---

## API Testing Checklist

- [ ] register user
- [ ] login user
- [ ] refresh token
- [ ] get profile
- [ ] create chat
- [ ] send chat message
- [ ] retrieve chat history
- [ ] save memory
- [ ] retrieve memory
- [ ] upload document
- [ ] query document
- [ ] create journal entry
- [ ] retrieve journal entry

---

## AI/RAG Testing Checklist

- [ ] memory vector can be added
- [ ] memory vector can be searched
- [ ] document chunk vector can be added
- [ ] document vector can be searched
- [ ] journal vector can be added
- [ ] journal vector can be searched
- [ ] Redis cache works for memory retrieval
- [ ] prompt receives retrieved context

---

## Deployment Testing Checklist

- [ ] backend deployed
- [ ] FastAPI deployed
- [ ] PostgreSQL connected
- [ ] Redis connected
- [ ] vector DB connected
- [ ] environment variables configured
- [ ] CORS configured
- [ ] Flutter app connected to production backend
- [ ] WebSocket works with WSS
- [ ] basic chat tested
- [ ] document Q&A tested
- [ ] memory flow tested
