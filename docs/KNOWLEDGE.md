# silver-bullet — Project Knowledge

> Gateway index and accumulated project intelligence.
> Claude reads this at session startup. Claude updates Part 2 at step 15 (documentation).
> **Never delete or edit prior entries.** All additions are append-only with date stamps.

---

## Part 1 — Gateway Index

| Doc | Path | Status |
|-----|------|--------|
| Master PRD | `docs/Master-PRD.md` | draft |
| Architecture | `docs/Architecture-and-Design.md` | draft |
| Testing Strategy | `docs/Testing-Strategy-and-Plan.md` | draft |
| CI/CD | `docs/CICD.md` | draft |
| Active Workflow | `docs/workflows/full-dev-cycle.md` | active |
| Specs | `docs/specs/` | 2 specs |
| Task Log | `docs/CHANGELOG.md` | — |
| Session Logs | `docs/sessions/` | 0 sessions |
| Git Repo | https://github.com/alo-exp/silver-bullet.git | — |

**Running virtual cost total:** $0.00 (estimated)

---

## Part 2 — Accumulated Intelligence

> Each entry: `YYYY-MM-DD — <note>`. Append below existing entries. Never edit above.

### Architecture patterns

2026-04-05 — Enforcement is split across two lists in `.silver-bullet.json`: `all_tracked` (discovery surface — hooks record the invocation) and `required_deploy` (hard gate — `completion-audit.sh` blocks commit/push/deploy if missing). Adding a skill to only `all_tracked` gives observability but not enforcement. Both lists must be mirrored in `templates/silver-bullet.config.json.default` so new projects inherit all enforcement rules.

2026-04-05 — `hooks/dev-cycle-check.sh` has a `finalization_skills` variable (line 205) that must stay in sync with `required_deploy`. Currently hardcoded — if a skill is added to `required_deploy` without updating `finalization_skills`, phase-skip detection silently misses the out-of-order case.

### Known gotchas

2026-04-05 — `accessibility-review` and `incident-response` must NOT be added to `required_deploy`. Both are conditional (UI-work path and DevOps incident path respectively). Adding them to `required_deploy` would cause `completion-audit.sh` to block commits on every non-UI and non-incident workflow run, producing constant false failures.

2026-04-05 — `templates/silver-bullet.config.json.default` is easy to forget when updating `.silver-bullet.json`. The two files must stay in exact parity on `required_deploy` and `all_tracked`. No CI currently enforces this — manual `diff` in code review is the current check.

### Key decisions

2026-04-05 — Chose v0.8.0 (semver minor) for Phase 2 because adding skills to `required_deploy` is a breaking change for existing users: `completion-audit.sh` will block their commits until they invoke `test-driven-development` and `tech-debt`. Breaking change must be prominently documented in release notes.

2026-04-05 — `tech-debt` replaces the pre-existing inline prose note ("**Tech-debt notes** (inline) — Append identified debt to `docs/tech-debt.md`") in FINALIZATION step 14. The prose note was informal and not enforced by any hook. The skill invocation is now required and enforcement-tracked.

### Recurring patterns

2026-04-05 — Every skill promoted to explicit enforcement requires 4 coordinated changes: (1) workflow doc REQUIRED marker, (2) template mirror update, (3) `.silver-bullet.json` `all_tracked` entry, (4) `required_deploy` entry if unconditional. Missing any one of these produces an inconsistency that surfaces as a documentation/enforcement gap.

### Open questions

2026-04-05 — Should `finalization_skills` in `dev-cycle-check.sh` be derived at runtime from `.silver-bullet.json` `required_deploy` rather than hardcoded? This would eliminate the sync gap but requires the hook to parse JSON on every tool invocation.
[RESOLVED 2026-04-05]: Deferred to a future refactor — tracked as tech debt (score 18). Current manual sync is acceptable while `required_deploy` changes are infrequent.

> To add: append `YYYY-MM-DD — <question>`
> To resolve: append `[RESOLVED YYYY-MM-DD]: <resolution>` below the original question
