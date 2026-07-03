# Aura AI — Backend

FastAPI backend for Aura AI (Flutter-based personal AI companion).
Implements the Core Backend Services, API Gateway, and AI Orchestration layers
from the system architecture.

## Stack
- **FastAPI** — REST API
- **PostgreSQL** (SQLAlchemy) — primary DB (users, chats, messages, memory, documents)
- **Redis** — sessions / rate limiting / cache (to be wired in)
- **JWT** — authentication
- **OpenRouter** — LLM calls (swap for any provider)

## Project Structure