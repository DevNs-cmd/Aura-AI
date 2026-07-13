# API Documentation

This document describes the planned Aura AI API structure.

---

## API Ownership

| API Area | Service |
|---|---|
| Authentication | NestJS |
| User Management | NestJS |
| Chat APIs | NestJS |
| WebSocket | NestJS |
| AI Processing | FastAPI |
| Memory Retrieval | FastAPI |
| Document Intelligence | FastAPI |
| Vector Search | FastAPI |

---

## Authentication APIs

### Register

```http
POST /auth/register
```

Request:

```json
{
  "name": "Atharva",
  "email": "user@example.com",
  "password": "securePassword"
}
```

### Login

```http
POST /auth/login
```

Request:

```json
{
  "email": "user@example.com",
  "password": "securePassword"
}
```

### Refresh Token

```http
POST /auth/refresh
```

### Logout

```http
POST /auth/logout
```

---

## User APIs

```http
GET /users/me
PUT /users/me
DELETE /users/me
```

---

## Chat APIs

```http
POST /chat
GET /chat/history
GET /chat/sessions
GET /chat/:id
DELETE /chat/:id
```

Chat request:

```json
{
  "chat_id": "uuid",
  "message": "Explain my document"
}
```

---

## Memory APIs

```http
GET /memory
POST /memory
DELETE /memory/:id
```

---

## Document APIs

```http
POST /documents/upload
GET /documents
GET /documents/:id
DELETE /documents/:id
POST /documents/:id/ask
```

---

## Journal APIs

```http
POST /journal
GET /journal
GET /journal/:id
PUT /journal/:id
DELETE /journal/:id
```

---

## Internal FastAPI AI Endpoints

These endpoints are internal and should be called by NestJS, not directly by Flutter.

```http
POST /ai/chat
POST /ai/memory/retrieve
POST /ai/documents/process
POST /ai/documents/query
POST /ai/journal/analyze
GET /health/chroma
```

---

## Health APIs

```http
GET /health
GET /health/postgres
GET /health/redis
GET /health/chroma
```

---

## Standard Success Response

```json
{
  "success": true,
  "message": "Request completed successfully",
  "data": {}
}
```

---

## Standard Error Response

```json
{
  "success": false,
  "message": "Something went wrong",
  "error": "ERROR_CODE"
}
```
