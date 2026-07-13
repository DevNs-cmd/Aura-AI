# Environment Variables

This document lists the environment variables used by Aura AI.

---

## PostgreSQL

```env
POSTGRES_USER=aura_user
POSTGRES_PASSWORD=aura_password
POSTGRES_DB=aura_ai
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
DATABASE_URL=postgresql://aura_user:aura_password@localhost:5432/aura_ai
```

---

## Redis

```env
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_URL=redis://localhost:6379
```

---

## ChromaDB

```env
CHROMA_HOST=localhost
CHROMA_PORT=8001
VECTOR_DB_PROVIDER=chroma
```

---

## Pinecone Future Option

```env
PINECONE_API_KEY=
PINECONE_INDEX_NAME=
```

---

## AI Providers

```env
OPENAI_API_KEY=
GEMINI_API_KEY=
```

---

## NestJS Backend

```env
NODE_ENV=development
PORT=5000
JWT_SECRET=aura_dev_secret
JWT_REFRESH_SECRET=aura_refresh_secret
FRONTEND_URL=http://localhost:3000
FASTAPI_BASE_URL=http://127.0.0.1:8000
```

---

## FastAPI AI Service

```env
FASTAPI_HOST=0.0.0.0
FASTAPI_PORT=8000
```

---

## Production Backend Example

```env
NODE_ENV=production
PORT=5000
JWT_SECRET=replace_with_secure_secret
JWT_REFRESH_SECRET=replace_with_secure_refresh_secret
FRONTEND_URL=https://your-frontend-domain.com
FASTAPI_BASE_URL=https://your-fastapi-service.onrender.com
DATABASE_URL=postgresql://user:password@host:5432/aura_ai
REDIS_URL=redis://default:password@host:6379
```

---

## Production FastAPI Example

```env
DATABASE_URL=postgresql://user:password@host:5432/aura_ai
REDIS_URL=redis://default:password@host:6379
OPENAI_API_KEY=
GEMINI_API_KEY=
VECTOR_DB_PROVIDER=chroma
CHROMA_HOST=
CHROMA_PORT=
PINECONE_API_KEY=
PINECONE_INDEX_NAME=
```

---

## Security Notes

- do not commit `.env`
- commit only `.env.example`
- use deployment platform secrets
- rotate exposed keys
- use strong JWT secrets
- use managed database credentials in production
