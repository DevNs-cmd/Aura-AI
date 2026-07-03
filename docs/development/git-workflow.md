# Git workflow (Aura AI)

## Purpose
Define how the shared repository is managed across multiple contributors.

## Scope
Applies to all repository changes.

## Contents
- Branch naming convention
- Pull request rules
- Code review rules
- Merge strategy

## Related Documents
- Root `README.md`

## How to contribute
When uncertain about process, document the rationale in the PR description and request review.

---

## Branch naming convention
Use these lowercase prefixes:
- `feature/` — new functionality
- `fix/` — bug fixes
- `chore/` — maintenance, refactors, CI/docs changes

Examples:
- `chore/repository-initialization`

---

## Pull request (PR) rules
1. Open PR from a non-`main` branch.
2. PR title should summarize the scope.
3. PR description must include:
   - What changed
   - Why it changed
   - Validation steps (build/test commands)

---

## Code review rules
- Structural refactors must have reviewers confirm:
  - No business logic changes
  - No API/route changes
  - No dependency changes
- At least one reviewer must approve.

---

## No direct commits to `main`
- Changes must be delivered via PR.

---

## Merge strategy
- Prefer **squash merge**.
- Ensure PR is up to date and passes required checks before merging.

