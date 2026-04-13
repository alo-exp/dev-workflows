# Enforcement Architecture

Silver Bullet enforces workflow compliance through 7 independent layers. No single layer can be bypassed in isolation — they compose to provide defense-in-depth.

## The 7 Layers

| # | Layer | Mechanism | Fires On | What It Prevents |
|---|-------|-----------|----------|-----------------|
| 1 | **Skill Recording** | `record-skill.sh` (PostToolUse) | Every Skill tool call | Skills invoked but not tracked |
| 2 | **Dev Cycle Gate** | `dev-cycle-check.sh` (PreToolUse) | Edit, Write, Bash | Code changes before planning is complete |
| 3 | **Completion Audit** | `completion-audit.sh` (PostToolUse) | git commit/push/deploy/release | Shipping without required skills |
| 4 | **CI Status Check** | `ci-status-check.sh` (PostToolUse) | git commit/push | Committing while CI is red |
| 5 | **Compliance Score** | `compliance-status.sh` (PostToolUse) | Every tool call | Silent progress — emits live score |
| 6 | **Phase Archive** | `phase-archive.sh` (PreToolUse) | `gsd-tools phases clear` | Data loss on milestone clear |
| 7 | **Model Routing** | `ensure-model-routing.sh` (PreToolUse) | Agent tool calls | Wrong model for task type |

## Dev Cycle Gate (4-Stage)

`dev-cycle-check.sh` enforces a sequential workflow via 4 stages:

| Stage | Requires | Blocks Until |
|-------|----------|-------------|
| A — Quality Gates | `quality-gates` in state | Design-phase quality review done |
| B — Planning | Planning skills in state | GSD planning complete |
| C — Code Review | `code-review` in state | Review before finalization |
| D — Finalization | All `required_deploy` skills | All required skills invoked |

## Skill Classification

| List | Purpose | Enforcement |
|------|---------|-------------|
| `all_tracked` | Discovery — hooks record invocation | Observability only |
| `required_deploy` | Hard gate — must be in state before shipping | `completion-audit.sh` blocks commit/push |

Current `required_deploy`: `test-driven-development`, `tech-debt`, `verification-before-completion`

Conditional skills (NOT in `required_deploy`): `accessibility-review` (UI only), `incident-response` (DevOps only)

## Pre-Release Quality Gate (4-Stage)

Before any release, 4 stages must pass in the current session:

| Stage | What | Enforcement |
|-------|------|-------------|
| 1 | Code Review Triad | Loop until zero accepted issues |
| 2 | Big-Picture Consistency Audit | Two consecutive clean passes |
| 3 | Public-Facing Content Refresh | All user surfaces current |
| 4 | Security Audit (SENTINEL) | Two consecutive clean passes |

Each stage requires explicit `/superpowers:verification-before-completion` invocation. Stage markers are cleared on session start — no stale markers.

## Bypass Detection

Silver Bullet detects and blocks:
- Out-of-order skill invocation (finalization before review)
- State file tampering (session-start validation)
- Hook skip attempts (hooks fire on every tool call, not just session start)
- Trivial-mode abuse (requires explicit user confirmation)

## Scalability

**Fixed** — this document describes structural layers that change only when enforcement architecture changes. Not append-only.
