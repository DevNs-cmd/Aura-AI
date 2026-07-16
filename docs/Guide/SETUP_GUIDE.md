# Setup Guide

This guide explains how to set up Aura AI locally.

---

## Prerequisites

Install:

- Git
- Node.js 18+
- Python 3.10+
- Docker Desktop
- Flutter SDK
- VS Code

---

## Clone Repository

```bash
git clone https://github.com/DevNs-cmd/Aura-AI.git
cd Aura-AI
```

---

## Create Environment File

Linux/macOS:

```bash
cp .env.example .env
```

Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

Update `.env` values.

---

## Start Database Services

```bash
docker compose up -d
```

Verify:

```bash
docker ps
```

Expected:

```text
aura_postgres
aura_redis
aura_chromadb
```

---

## Install NestJS Backend Dependencies

```bash
npm install
```

---

## Install FastAPI Dependencies

```bash
pip install -r requirements.txt
```

---

## Run NestJS Backend

```bash
npm run start:dev
```

If this script is unavailable, check scripts:

```bash
npm run
```

---

## Run FastAPI AI Service

```bash
python -m uvicorn app.main:app --reload --port 8000
```

Open:

```text
http://127.0.0.1:8000/docs
```

---

## Verify PostgreSQL

```bash
docker exec -it aura_postgres psql -U aura_user -d aura_ai
```

Then:

```sql
\dt
```

---

## Verify Redis

```bash
docker exec -it aura_redis redis-cli
PING
```

Expected:

```text
PONG
```

---

## Verify ChromaDB

ChromaDB should be available on:

```text
http://localhost:8001
```

---

## Recommended Local Run Order

```text
1. Start Docker Desktop
2. docker compose up -d
3. Run FastAPI AI service
4. Run NestJS backend
5. Run Flutter app
```

---

## Stop Services

```bash
docker compose down
```

Stop and remove local volumes:

```bash
docker compose down -v
```

Warning: this deletes local database data.
