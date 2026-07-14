# Backend README

This file documents the NestJS backend layer of Aura AI.

---

## Backend Ownership

Backend services are handled by NestJS.

```text
Flutter App → NestJS Backend → FastAPI AI Service
```

---

## Responsibilities

The NestJS backend handles:

- authentication
- user management
- chat APIs
- session management
- request validation
- guards
- rate limiting
- WebSocket gateway
- communication with FastAPI AI service
- core backend business logic
- PostgreSQL operations for backend records
- Redis usage for sessions/cache/rate limits

---

## Tech Stack

- NestJS
- TypeScript
- JWT authentication
- PostgreSQL
- Redis
- WebSocket gateway

---

## Local Development

Install dependencies:

```bash
npm install
```

Run backend:

```bash
npm run start:dev
```

Check scripts:

```bash
npm run
```

---

## Production Build

```bash
npm run build
npm run start:prod
```

---

## Required Environment Variables

```env
NODE_ENV=development
PORT=5000
JWT_SECRET=
JWT_REFRESH_SECRET=
DATABASE_URL=
REDIS_URL=
FASTAPI_BASE_URL=http://127.0.0.1:8000
FRONTEND_URL=http://localhost:3000
```

---

## Backend Deployment

Recommended platforms:

- Render
- Railway

Render build command:

```bash
npm install && npm run build
```

Render start command:

```bash
npm run start:prod
```

---

## Backend to FastAPI Communication

NestJS should call FastAPI for:

- AI chat completion
- memory retrieval
- document processing
- document Q&A
- journal analysis
- vector search

Example internal URL:

```env
FASTAPI_BASE_URL=https://your-fastapi-service.onrender.com
```

---

## Important Rule

Do not mix Express backend implementation into the production backend structure because the final backend service is NestJS.
