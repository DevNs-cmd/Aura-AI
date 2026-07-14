# Deployment Guide

This guide explains deployment preparation for Aura AI.

---

## Deployment Architecture

```text
Flutter App
   ↓
NestJS Backend
   ↓
FastAPI AI Service
   ↓
PostgreSQL / Redis / ChromaDB or Pinecone
```

---

## Recommended Platforms

| Component | Recommended Platform |
|---|---|
| Flutter Web/Admin | Vercel |
| Flutter Mobile | Play Store / App Store |
| NestJS Backend | Render / Railway |
| FastAPI AI Service | Render / Railway |
| PostgreSQL | Render PostgreSQL / Supabase / Neon |
| Redis | Upstash / Render Redis |
| Vector DB | ChromaDB self-hosted / Pinecone |
| File Storage | S3 / Cloudinary / Firebase Storage |

---

## NestJS Backend Deployment on Render

### Render Settings

```text
Environment: Node
Root Directory: .
Build Command: npm install && npm run build
Start Command: npm run start:prod
```

### Required `package.json` Scripts

```json
{
  "scripts": {
    "start": "node dist/main.js",
    "start:dev": "nest start --watch",
    "start:prod": "node dist/main.js",
    "build": "nest build"
  }
}
```

### Backend Environment Variables

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

## FastAPI AI Service Deployment on Render

### Render Settings

```text
Environment: Python
Root Directory: .
Build Command: pip install -r requirements.txt
Start Command: uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

### FastAPI Environment Variables

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

## Vercel Frontend Deployment

If Flutter web/admin is deployed on Vercel, configure:

```env
API_BASE_URL=https://your-nest-backend.onrender.com
WS_BASE_URL=wss://your-nest-backend.onrender.com
FASTAPI_BASE_URL=https://your-fastapi-service.onrender.com
```

For Flutter mobile, production API URL should be configured in the app environment/config file.

---

## Optional `render.yaml` Example

```yaml
services:
  - type: web
    name: aura-nest-backend
    env: node
    buildCommand: npm install && npm run build
    startCommand: npm run start:prod
    envVars:
      - key: NODE_ENV
        value: production
      - key: DATABASE_URL
        sync: false
      - key: REDIS_URL
        sync: false
      - key: JWT_SECRET
        sync: false
      - key: FASTAPI_BASE_URL
        sync: false

  - type: web
    name: aura-fastapi-ai
    env: python
    buildCommand: pip install -r requirements.txt
    startCommand: uvicorn app.main:app --host 0.0.0.0 --port $PORT
    envVars:
      - key: DATABASE_URL
        sync: false
      - key: REDIS_URL
        sync: false
      - key: OPENAI_API_KEY
        sync: false
      - key: GEMINI_API_KEY
        sync: false
```

---

## Docker Local Deployment

```bash
docker compose up -d
```

---

## Production Checklist

- [ ] production database created
- [ ] production Redis created
- [ ] vector DB selected
- [ ] backend deployed
- [ ] FastAPI deployed
- [ ] frontend configured
- [ ] environment variables added
- [ ] CORS configured
- [ ] HTTPS enabled
- [ ] WSS enabled
- [ ] health endpoints pass
- [ ] chat flow tested
- [ ] memory flow tested
- [ ] document upload tested
- [ ] logs checked
