# Local setup (Aura AI)

## Purpose
Provide repeatable steps for setting up the monorepo locally.

## Scope
Backend, frontend (Flutter), and database components.

## Contents
- Environment setup
- Backend setup
- Frontend setup
- Database setup
- Common run commands

## Related Documents
- `docs/development/git-workflow.md`
- `docs/backend/README.md`

## How to contribute
If commands/config diverge from actual code, propose corrections via PR.

---

## Environment setup
### Backend environment
1. Copy `backend/.env.example` to `backend/.env`.
2. Update values as needed (no secrets should be committed).

### Expected backend variables
- `PORT`
- Database connection:
  - `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`
- Redis connection:
  - `REDIS_HOST`, `REDIS_PORT`
- Firebase configuration:
  - `FIREBASE_CONFIG`

---

## Backend setup
From repo root:

```bash
cd backend
npm install
npm run build
npm run start:dev
```

Expected base URL:
- `http://localhost:3000/api/v1`

---

## Frontend setup (Flutter)
From repo root:

```bash
cd frontend
flutter pub get
flutter run
```

---

## Database setup
1. Review `database/schema/`.
2. Apply migrations from `database/migrations/`.
3. Seed data using `database/seed/` scripts.

---

## Run commands (quick reference)
- Backend dev: `cd backend && npm run start:dev`
- Backend build: `cd backend && npm run build`

