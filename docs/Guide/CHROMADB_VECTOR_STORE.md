# ChromaDB Vector Store

ChromaDB is used as the MVP vector database for Aura AI.

---

## Purpose

ChromaDB stores embeddings for semantic search across:

- user memories
- document chunks
- journal entries

---

## Collections

```text
aura_memories
aura_documents
aura_journals
```

---

## Memory Collection

Stores long-term user memory vectors.

Metadata example:

```json
{
  "user_id": "user_uuid",
  "source_id": "memory_uuid",
  "type": "preference"
}
```

---

## Document Collection

Stores uploaded document chunk vectors.

Metadata example:

```json
{
  "user_id": "user_uuid",
  "document_id": "document_uuid",
  "chunk_index": 1,
  "file_name": "notes.pdf"
}
```

---

## Journal Collection

Stores journal entry vectors.

Metadata example:

```json
{
  "user_id": "user_uuid",
  "journal_id": "journal_uuid",
  "mood": "stressed"
}
```

---

## Search Flow

```text
User query
   ↓
Embedding generated
   ↓
ChromaDB similarity search
   ↓
Relevant vectors returned
   ↓
Context passed into AI prompt
```

---

## ID Mapping

PostgreSQL stores permanent source data.

ChromaDB stores vector representation.

Example:

```text
PostgreSQL memories.id = 123
ChromaDB vector id = memory_123
```

---

## Health Check

```http
GET /health/chroma
```

Expected response:

```json
{
  "status": "connected",
  "collections": [
    "aura_memories",
    "aura_documents",
    "aura_journals"
  ]
}
```

---

## ChromaDB vs Pinecone

| Feature | ChromaDB | Pinecone |
|---|---|---|
| Type | Local/self-hosted | Cloud managed |
| Used in MVP | Yes | No |
| API key required | No | Yes |
| Production scale | Limited | Strong |
| Current status | MVP vector store | Future option |

---

## Production Note

If ChromaDB hosting becomes difficult during deployment, use Pinecone.

```env
VECTOR_DB_PROVIDER=pinecone
PINECONE_API_KEY=
PINECONE_INDEX_NAME=
```
