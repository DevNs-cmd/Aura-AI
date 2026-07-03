# Backend

## Purpose
Document the backend service responsibilities, boundaries, and local development expectations.

## Scope
NestJS backend (API server), including module organization under `backend/src/`.

## Contents
- Responsibilities
- Project structure
- How to run locally
- Validation / safety checks

## Related Documents
- `docs/api/README.md`
- `docs/development/local-setup.md`

## How to contribute
Propose updates via PR. Avoid modifying business logic; keep documentation aligned with actual code structure.

---

## Responsibilities
- Expose REST endpoints under the configured API prefix.
- Provide authentication/session support.
- Provide domain services used by the frontend.

## Project structure
- `backend/src/main.ts` — Nest bootstrap entrypoint
- `backend/src/app.module.ts` — root Nest module
- `backend/src/*` — feature modules (auth, users, session, notification, etc.)

## How to run locally
See `docs/development/local-setup.md`.

## Validation / safety checks
During structural refactors:
- Preserve routes, controllers, services, DTOs, entities, and business logic.
- Update import paths only when moving files.

