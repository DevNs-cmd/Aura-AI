# Security Policy

This document defines the security practices for Aura AI.

Aura AI handles sensitive user data such as conversations, memories, documents, and journal entries. The system must be designed and deployed with secure defaults.

---

## Sensitive Data

Never commit the following:

```text
.env
.env.local
API keys
JWT secrets
database passwords
Redis passwords
OpenAI keys
Gemini keys
Pinecone keys
private certificates
production URLs containing secrets
```

Only `.env.example` should be committed.

---

## Authentication Security

Authentication should be handled by the NestJS backend.

Recommended requirements:

- JWT access tokens
- refresh tokens
- bcrypt password hashing
- token expiration
- refresh token rotation
- logout token invalidation
- protected routes using guards
- secure password reset flow

---

## API Security

All APIs should include:

- request validation
- authentication middleware/guards
- role-based access where required
- rate limiting
- safe error responses
- no internal stack traces in production
- input sanitization
- upload validation
- CORS restrictions

---

## CORS Policy

Development may allow local origins.

Production should only allow trusted frontend URLs.

```env
FRONTEND_URL=https://your-production-frontend.com
```

Do not use this in production:

```text
*
```

---

## File Upload Security

Document upload must validate:

- file size
- file extension
- MIME type
- user ownership
- storage path
- malicious file risk

Recommended allowed document types:

```text
pdf
doc
docx
txt
md
```

---

## Database Security

PostgreSQL should use:

- strong production password
- managed database in production
- private network access where available
- regular backups
- least-privilege database user
- SSL/TLS connection where supported

Passwords must never be stored as plaintext.

---

## Redis Security

Production Redis should:

- use authentication
- use TLS where available
- not be publicly exposed
- avoid permanent storage of sensitive data
- apply TTLs to temporary keys
- be accessed only by backend services

---

## Vector Store Security

ChromaDB or Pinecone stores vector representations of user content.

Recommended practices:

- attach `user_id` metadata to every vector
- filter vector queries by authenticated `user_id`
- never return another user's vectors
- delete vectors when user deletes source data
- avoid storing unnecessary sensitive metadata

---

## AI Provider Security

API keys for OpenAI/Gemini/Pinecone must be stored in deployment platform secrets.

Never log:

- API keys
- full prompts containing private data
- raw document content in production logs
- user memory without masking

---

## Production Checklist

- [ ] `.env` not committed
- [ ] secrets stored in platform environment variables
- [ ] JWT secrets changed from development values
- [ ] CORS restricted
- [ ] HTTPS enabled
- [ ] WSS enabled for WebSocket
- [ ] database credentials rotated
- [ ] Redis not public
- [ ] upload validation enabled
- [ ] rate limiting enabled
- [ ] error messages sanitized

---

## Reporting Security Issues

Report security issues privately to the project owner/team lead. Do not post secrets or vulnerabilities in public group chats.
