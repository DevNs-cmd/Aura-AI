# Changelog

All notable changes to Aura AI will be documented in this file.

---

## [Unreleased]

### Added

- Complete project `README.md`
- `SECURITY.md`
- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `ARCHITECTURE.md`
- `API_DOCUMENTATION.md`
- `SETUP_GUIDE.md`
- `DEPLOYMENT_GUIDE.md`
- `ENVIRONMENT_VARIABLES.md`
- `WEBSOCKET_DOCUMENTATION.md`
- `REDIS_CACHE_STRATEGY.md`
- `CHROMADB_VECTOR_STORE.md`
- `TESTING_GUIDE.md`
- `TROUBLESHOOTING.md`
- `BACKEND_README.md`
- `DATABSE_README.md`
- `FRONTEND_README.md`

### Infrastructure Added

- Docker Compose setup for PostgreSQL, Redis, and ChromaDB
- PostgreSQL schema documentation
- PostgreSQL seed data documentation
- Redis cache strategy documentation
- ChromaDB vector store documentation
- Deployment command documentation for Render/Vercel-style platforms

### Architecture Clarified

Confirmed system flow:

```text
Flutter App → NestJS Backend → FastAPI AI Service → PostgreSQL / Redis / ChromaDB
```

### Notes

- ChromaDB is used for MVP local vector storage.
- Pinecone is kept as a future production option.
- Express.js reference implementation is not part of the final production architecture.
