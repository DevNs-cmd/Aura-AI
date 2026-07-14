# Aura AI

Aura AI is a mobile-first AI companion application designed to provide intelligent conversation, persistent memory, document understanding, journaling support, and personalized AI assistance.

This documentation is written for development, testing, polishing, and deployment readiness.

---

## Confirmed Architecture

```text
Flutter Mobile App
        ↓
NestJS Backend Service
        ↓
FastAPI AI Service
        ↓
PostgreSQL / Redis / ChromaDB
```

---

## Project Vision

Aura AI aims to become a personal AI companion that can:

- communicate naturally with users
- remember useful user preferences and context
- answer questions from uploaded documents
- support journaling and reflection
- retrieve relevant memory during conversations
- provide intelligent, personalized, context-aware responses

---

## MVP Scope

### Included in MVP

- Flutter mobile application
- Authentication flow
- Chat interface
- Persistent chat history
- Basic long-term memory support
- Document upload and document-based Q&A
- Journal entry support
- FastAPI AI service
- NestJS backend API layer
- PostgreSQL database
- Redis cache layer
- ChromaDB vector database
- Deployment-ready documentation

### Not Included in MVP

- Payment/subscription system
- Advanced voice assistant
- Vision/image intelligence
- Multi-tenant enterprise dashboard
- Kubernetes-based production scaling
- Advanced analytics dashboard
- Full production-grade observability stack

### Future Scope

- Pinecone production vector database
- Voice input/output
- Image understanding
- Background workers for heavy document processing
- Admin analytics dashboard
- Usage billing and subscription plans
- Advanced personalization engine
- CI/CD automation
- Monitoring, tracing, and alerting

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter, Dart |
| Backend Service | NestJS, TypeScript |
| AI Service | FastAPI, Python |
| Primary Database | PostgreSQL |
| Cache Layer | Redis |
| Vector Database | ChromaDB |
| Future Vector DB | Pinecone |
| AI Providers | OpenAI / Gemini |
| Local Infrastructure | Docker Compose |
| Backend Deployment | Render / Railway |
| Frontend Deployment | Vercel / Firebase / Play Store |
| Database Hosting | Render PostgreSQL / Supabase / Neon |
| Redis Hosting | Upstash / Render Redis |

---

## Service Ownership

| Service | Responsibility |
|---|---|
| Flutter App | UI, mobile screens, API calls, WebSocket client |
| NestJS Backend | Auth, user APIs, chat APIs, sessions, WebSocket gateway, validation |
| FastAPI AI Service | AI orchestration, embeddings, RAG, memory retrieval, document intelligence |
| PostgreSQL | Users, chats, messages, memories, documents, journals |
| Redis | Sessions, rate limiting, chat context cache, memory cache, WebSocket state |
| ChromaDB | Memory vectors, document vectors, journal vectors |

---

## Repository Documentation Index

| File | Purpose |
|---|---|
| `README.md` | Main project overview |
| `ARCHITECTURE.md` | Complete architecture and Mermaid diagram |
| `API_DOCUMENTATION.md` | REST API and internal AI endpoint documentation |
| `SETUP_GUIDE.md` | Local setup instructions |
| `DEPLOYMENT_GUIDE.md` | Render/Vercel/Railway deployment guide |
| `ENVIRONMENT_VARIABLES.md` | Environment variable reference |
| `WEBSOCKET_DOCUMENTATION.md` | WebSocket flow and events |
| `REDIS_CACHE_STRATEGY.md` | Redis keys, TTLs, and cache flow |
| `CHROMADB_VECTOR_STORE.md` | ChromaDB collections and vector strategy |
| `TESTING_GUIDE.md` | Testing checklist |
| `TROUBLESHOOTING.md` | Common errors and fixes |
| `BACKEND_README.md` | NestJS backend guide |
| `DATABSE_README.md` | Database guide |
| `FRONTEND_README.md` | Flutter frontend guide |
| `SECURITY.md` | Security policy |
| `CONTRIBUTING.md` | Contribution workflow |
| `CODE_OF_CONDUCT.md` | Team collaboration rules |
| `CHANGELOG.md` | Project change history |

---

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/DevNs-cmd/Aura-AI.git
cd Aura-AI
```

### 2. Create Environment File

```bash
cp .env.example .env
```

Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

### 3. Start Local Infrastructure

```bash
docker compose up -d
```

Expected containers:

```text
aura_postgres
aura_redis
aura_chromadb
```

### 4. Install NestJS Dependencies

```bash
npm install
```

### 5. Install FastAPI Dependencies

```bash
pip install -r requirements.txt
```

### 6. Run NestJS Backend

```bash
npm run start:dev
```

### 7. Run FastAPI AI Service

```bash
python -m uvicorn app.main:app --reload --port 8000
```

### 8. Open FastAPI Swagger

```text
http://127.0.0.1:8000/docs
```

---

## Current Development Status

The project currently has:

- defined Flutter mobile-first product direction
- NestJS backend service layer
- FastAPI AI service layer
- PostgreSQL schema and seed setup
- Redis cache strategy
- ChromaDB vector store strategy
- Docker Compose local infrastructure
- deployment-ready documentation

---

## Deployment Goal

After testing and polishing, the project should be deployable with:

- NestJS backend deployed on Render/Railway
- FastAPI AI service deployed on Render/Railway
- PostgreSQL hosted database
- Redis hosted cache
- ChromaDB self-hosted or Pinecone in production
- Flutter app connected to production API URLs
