# Aura AI — Backend

FastAPI backend for Aura AI (Flutter-based personal AI companion).
Implements the Core Backend Services, API Gateway, and AI Orchestration layers
from the system architecture.

## Stack
- **FastAPI** — REST API
- **PostgreSQL** (SQLAlchemy) — primary DB (users, chats, messages, memory, documents)
- **Redis** — sessions / rate limiting / cache (to be wired in)
- **JWT** — authentication
- **OpenRouter** — LLM calls (swap for any provider)

## Project Structure
```
app/
  core/            # config, security (JWT, password hashing)
  db/              # SQLAlchemy engine/session
  models/          # ORM models: User, ChatSession, Message, Memory, Document
  schemas/         # Pydantic request/response schemas
  api/
    deps.py        # shared dependencies (get_current_user)
    v1/endpoints/  # auth, user, chat, document routers
  services/        # business logic (chat_service = AI orchestrator)
  main.py          # app entrypoint, CORS, rate limiting
```

## Setup

1. Create virtual environment:
   ```
   python -m venv venv
   venv\Scripts\activate      # Windows PowerShell
   ```

2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

3. Copy `.env.example` to `.env` and fill in real values:
   ```
   copy .env.example .env
   ```
   **Never commit `.env` — it's already in `.gitignore`.**

4. Make sure PostgreSQL is running and `DATABASE_URL` in `.env` points to it.

5. Run the server:
   ```
   uvicorn app.main:app --reload
   ```

6. Open API docs: http://localhost:8000/docs

## Endpoints (v1)

| Method | Path | Description |
|---|---|---|
| POST | `/api/v1/auth/register` | Create account |
| POST | `/api/v1/auth/login` | Get access + refresh token |
| POST | `/api/v1/auth/refresh` | Refresh access token |
| GET | `/api/v1/users/me` | Current user profile |
| POST | `/api/v1/chat/sessions` | Start new chat session |
| GET | `/api/v1/chat/sessions` | List my chat sessions |
| GET | `/api/v1/chat/sessions/{id}` | Get session + messages |
| POST | `/api/v1/chat/sessions/{id}/messages` | Send message, get AI reply |
| POST | `/api/v1/documents/upload` | Upload a document |
| GET | `/api/v1/documents` | List my documents |

All endpoints except `/auth/*` require:
`Authorization: Bearer <access_token>`

## Next steps (not yet built)
- RAG pipeline (chunking, embeddings, vector search) for document Q&A
- Redis-backed short-term memory / session cache
- Notification service
- Background job (Celery/RQ) to process uploaded documents
- Alembic migrations instead of `create_all`
