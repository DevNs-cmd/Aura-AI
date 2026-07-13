# Contributing Guide

This guide explains how contributors should work on Aura AI.

---

## Core Collaboration Rule

Before changing architecture, folder structure, deployment strategy, or shared documentation:

```text
Inform the group
Get confirmation
Then update the repo
```

---

## Branch Naming

Use clear branch names.

```text
feature/feature-name
fix/bug-name
docs/documentation-update
refactor/module-name
chore/task-name
```

Examples:

```text
feature/database-redis-chromadb
docs/deployment-guide
fix/redis-connection
```

---

## Commit Message Style

Use meaningful commit messages.

Good examples:

```text
Add database infrastructure documentation
Update deployment guide
Fix Redis connection configuration
Add ChromaDB vector store documentation
```

Avoid:

```text
final
changes
update
done
```

---

## Development Workflow

```text
Create feature branch
        ↓
Make changes
        ↓
Test locally
        ↓
Update documentation
        ↓
Check git status
        ↓
Commit
        ↓
Push
        ↓
Create Pull Request
        ↓
Review
        ↓
Merge
```

---

## Pull Request Checklist

Before opening a PR:

- [ ] code runs locally
- [ ] related documentation updated
- [ ] `.env` is not committed
- [ ] `node_modules` is not committed
- [ ] `__pycache__` is not committed
- [ ] no unnecessary generated files are committed
- [ ] folder structure is clean
- [ ] PR description explains the change
- [ ] testing steps are included

---

## Project Architecture Rule

Confirmed architecture:

```text
Flutter App → NestJS Backend → FastAPI AI Service → PostgreSQL / Redis / ChromaDB
```

Do not mix Express implementation directly into the production backend structure because backend services are handled by NestJS.

---

## Code Ownership

| Area | Owner Service |
|---|---|
| Mobile UI | Flutter |
| Backend APIs | NestJS |
| Authentication | NestJS |
| WebSocket Gateway | NestJS |
| AI Orchestration | FastAPI |
| RAG / Embeddings | FastAPI |
| Primary Database | PostgreSQL |
| Cache | Redis |
| Vector Search | ChromaDB |

---

## Documentation Rule

Any major change must update related docs:

- architecture changes → `ARCHITECTURE.md`
- new environment variables → `ENVIRONMENT_VARIABLES.md`
- deployment changes → `DEPLOYMENT_GUIDE.md`
- API changes → `API_DOCUMENTATION.md`
- database changes → `DATABSE_README.md`
- Redis changes → `REDIS_CACHE_STRATEGY.md`
- vector DB changes → `CHROMADB_VECTOR_STORE.md`

---

## Review Checklist

Reviewers should check:

- security
- correctness
- readability
- folder structure
- docs update
- deployment impact
- no secrets committed
