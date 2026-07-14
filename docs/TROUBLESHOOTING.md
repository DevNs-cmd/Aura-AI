# Troubleshooting Guide

This guide lists common errors and fixes for Aura AI.

---

## Docker Warning: `version is obsolete`

If Docker shows:

```text
the attribute version is obsolete
```

This is only a warning. The services can still run.

Optional fix: remove the `version` line from `docker-compose.yml`.

---

## PostgreSQL Tables Not Created

Cause: Docker volume may already exist from an older setup.

Fix:

```bash
docker compose down -v
docker compose up -d
```

Warning: this deletes local database data.

---

## PostgreSQL Connection Test

```bash
docker exec -it aura_postgres psql -U aura_user -d aura_ai
```

Then:

```sql
\dt
```

---

## Redis Not Responding

Check logs:

```bash
docker logs aura_redis
```

Restart Redis:

```bash
docker restart aura_redis
```

Test:

```bash
docker exec -it aura_redis redis-cli
PING
```

Expected:

```text
PONG
```

---

## ChromaDB Not Responding

Check logs:

```bash
docker logs aura_chromadb
```

Restart:

```bash
docker restart aura_chromadb
```

---

## FastAPI Not Starting

Install dependencies:

```bash
pip install -r requirements.txt
```

Run:

```bash
python -m uvicorn app.main:app --reload --port 8000
```

Open:

```text
http://127.0.0.1:8000/docs
```

---

## NestJS Not Starting

Install dependencies:

```bash
npm install
```

Check available scripts:

```bash
npm run
```

Run development server:

```bash
npm run start:dev
```

---

## Port Already in Use

Windows PowerShell:

```powershell
netstat -ano | findstr :8000
taskkill /PID <PID> /F
```

```powershell
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

---

## Git Accidentally Added `node_modules`

Remove from Git tracking:

```bash
git rm -r --cached node_modules
```

Make sure `.gitignore` includes:

```text
node_modules/
```

---

## Git Accidentally Added `.env`

Remove from Git tracking:

```bash
git rm --cached .env
```

Make sure `.gitignore` includes:

```text
.env
```

---

## `LF will be replaced by CRLF` Warning

This is a Windows Git line-ending warning. It is usually safe to continue.

---

## ChromaDB Collection Missing

Restart ChromaDB and FastAPI:

```bash
docker restart aura_chromadb
python -m uvicorn app.main:app --reload --port 8000
```

Then test:

```text
GET /health/chroma
```

---

## Deployment API Not Connecting

Check:

- backend URL
- FastAPI URL
- CORS settings
- environment variables
- HTTPS vs HTTP
- WebSocket `ws://` vs `wss://`
- database credentials
- Redis credentials
