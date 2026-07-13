# Database README

This file documents the database layer for Aura AI.

> Note: The filename is kept as `DATABSE_README.md` because it was requested with this spelling.

---

## Database Stack

Aura AI uses:

- PostgreSQL for permanent structured data
- Redis for cache/session/rate-limit/temp context
- ChromaDB for vector search
- Pinecone as future production vector DB option

---

## PostgreSQL Tables

Main tables:

- users
- chats
- messages
- memories
- documents
- journal_entries

---

## users

Stores user account data.

Common fields:

```text
id
name
email
password_hash
avatar_url
created_at
updated_at
```

---

## chats

Stores chat sessions.

```text
id
user_id
title
created_at
updated_at
```

---

## messages

Stores chat messages.

```text
id
chat_id
role
content
created_at
```

---

## memories

Stores long-term memory metadata.

```text
id
user_id
content
type
embedding_id
importance
created_at
```

---

## documents

Stores document metadata.

```text
id
user_id
file_name
file_url
file_type
file_size
created_at
```

---

## journal_entries

Stores journal content.

```text
id
user_id
title
content
mood
embedding_id
created_at
updated_at
```

---

## Schema File

```text
app/db/init.sql
```

---

## Seed File

```text
app/db/seed.sql
```

---

## Start Database Services

```bash
docker compose up -d
```

Expected containers:

```text
aura_postgres
aura_redis
aura_chromadb
```

---

## PostgreSQL Access

```bash
docker exec -it aura_postgres psql -U aura_user -d aura_ai
```

List tables:

```sql
\dt
```

---

## Redis Access

```bash
docker exec -it aura_redis redis-cli
PING
```

Expected:

```text
PONG
```

---

## ChromaDB URL

```text
http://localhost:8001
```

---

## Backup

```bash
docker exec aura_postgres pg_dump -U aura_user aura_ai > aura_ai_backup.sql
```

---

## Restore

```bash
docker exec -i aura_postgres psql -U aura_user -d aura_ai < aura_ai_backup.sql
```

---

## Production Database Notes

For deployment, use managed services:

- PostgreSQL: Render PostgreSQL / Supabase / Neon
- Redis: Upstash / Render Redis
- Vector DB: Pinecone or self-hosted ChromaDB
