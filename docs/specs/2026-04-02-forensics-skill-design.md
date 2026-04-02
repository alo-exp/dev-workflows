# Silver Bullet — Forensics Skill Design

**Date:** 2026-04-02
**Scope:** Post-mortem investigation skill for completed or abandoned sessions
**Reference:** `docs/gsd2-vs-sb-gap-analysis.md` (Category 9 — Observability & Reporting)
**Target workflow:** `docs/workflows/full-dev-cycle.md`

---

## Problem

Silver Bullet has no structured post-mortem capability. When an autonomous session stalls, a task produces wrong output, or a completed session leaves things in a broken state, the only recourse is manually scanning session logs and git history. The existing `systematic-debugging` skill handles live bugs during execution — it is not designed for after-the-fact investigation of completed or abandoned sessions.

---

## Architecture: Pure Instruction Layer

The forensics skill is a SKILL.md that guides Claude through a symptom-driven investigation. No new hooks are needed — session logs (`docs/sessions/`), git history, and planning artifacts already provide all necessary evidence.

| Component | Type | Purpose |
|-----------|------|---------|
| `skills/forensics/SKILL.md` | New skill | Investigation workflow — classification, three paths, post-mortem |
| `docs/forensics/YYYY-MM-DD-<slug>.md` | Output artifact | Saved post-mortem reports |
| `CLAUDE.md` | Modify | Add `/forensics` rule alongside `/systematic-debugging` |
| `templates/CLAUDE.md.base` | Modify | Same addition |
| `docs/workflows/full-dev-cycle.md` | Modify | Add forensics invocation point in VERIFY section |
| `templates/workflows/full-dev-cycle.md` | Modify | Same addition |

The skill is invoked via the Skill tool as `/forensics` with an optional slug argument (e.g., `/forensics autonomous-stall-2026-04-02`). The slug defaults to `<failure-type>-<date>` if not supplied.

**Boundary with `systematic-debugging`:**
- `systematic-debugging` — live bugs **during** execution; find root cause before applying a fix
- `/forensics` — **completed or abandoned** sessions; post-mortem investigation of what went wrong

---

## Feature 1 — Failure Classification

When `/forensics` is invoked, Claude runs a two-step triage before entering any investigation path.

### Step 1 — User prompt

> "Briefly describe what went wrong. (e.g., 'autonomous session stalled after 20 min', 'task 3 produced wrong output', 'session completed but tests are failing')"

### Step 2 — Evidence quick-scan (parallel reads)

- Most recent session log in `docs/sessions/` (today's if available, otherwise most recent)
- `git log --oneline -10`
- Presence of `/tmp/.silver-bullet-timeout` (was sentinel triggered?)
- `.planning/` directory — any incomplete phase markers

### Classification

From the user description + quick-scan, Claude classifies into one of three paths:

| Path | Triggered when |
|------|---------------|
| **Session-level** | Timeout flag present; session log shows incomplete outcome; autonomous decisions log shows stall pattern; user describes stall/timeout/hang |
| **Task-level** | A specific task or phase is named; git history shows commits from the session but output is wrong; tests failing after recent commits |
| **General** | Does not fit neatly into the above — open-ended investigation |

Classification is logged as the first line of the post-mortem document.

---

## Feature 2 — Three Investigation Paths

### Path 1 — Session-level (stall / timeout / incomplete)

1. Read full session log — extract Mode, Autonomous decisions, Needs human review, Outcome
2. Check sentinel artifacts: was `/tmp/.silver-bullet-timeout` set? What was the last tool use before stall?
3. Run `git log --oneline` scoped to session date — how many commits landed vs. planned?
4. Read `.planning/ROADMAP.md` — which phases completed, which did not?
5. Identify: last confirmed progress point, where execution diverged, whether it was a blocker, stall, or external kill
6. Classify root cause as one of:
   - *Pre-answer gap* — a decision point was reached with no pre-answer and no autonomous fallback
   - *Anti-stall trigger* — per-step budget exceeded, counter not reset
   - *Genuine blocker* — missing credential, ambiguous destructive operation
   - *External kill* — terminal closed, session interrupted
   - *Unknown* — insufficient evidence to determine

### Path 2 — Task-level (wrong output)

1. Read the session log — find the relevant task in Files changed and Approach
2. Run `git show <commit>` for each commit from that task — what exactly changed?
3. Read the plan (`.planning/{phase}-PLAN.md`) — what was the task supposed to do?
4. Compare plan intent vs. actual diff — find the divergence point
5. Run tests if available (`npm test` / `pytest` / `cargo test` / `go test ./...`) — confirm which assertions fail
6. Classify root cause as one of:
   - *Plan ambiguity* — task was underspecified, Claude made a best-judgment call that was wrong
   - *Implementation drift* — Claude deviated from the plan without logging an autonomous decision
   - *Upstream dependency* — an earlier task produced bad input that propagated
   - *Verification gap* — tests did not catch the failure at the time of the commit

### Path 3 — General (open-ended)

1. Read most recent session log fully
2. Run `git log --oneline -20` + `git status`
3. Read any `.planning/` files modified in the last session
4. Ask one targeted follow-up question based on what the evidence shows
5. Proceed with the most applicable sub-path from Path 1 or Path 2 based on findings

### Root cause statement format (all paths)

All three paths end with a root cause statement in this format:

```
ROOT CAUSE: <one sentence> — <path taken> — <confidence: high/medium/low>
```

---

## Feature 3 — Post-mortem Document

Saved to `docs/forensics/YYYY-MM-DD-<slug>.md` after the investigation completes.

```markdown
# Forensics Report — <slug>

**Date:** YYYY-MM-DD
**Session log:** docs/sessions/<filename>.md
**Path taken:** session-level | task-level | general
**Confidence:** high | medium | low

---

## Symptom

<user's original description>

## Evidence Gathered

- Session log: <key findings>
- Git history: <relevant commits>
- Planning artifacts: <phase status>
- Test output: <pass/fail summary if applicable>
- Sentinel/timeout flags: <present/absent>

## Root Cause

<one-sentence root cause statement>

## Contributing Factors

- <factor 1>
- <factor 2>

## Recommended Next Steps

- [ ] <action 1>
- [ ] <action 2>

## Prevention

<one sentence on how to avoid this class of failure in future>
```

The `docs/forensics/` directory is created on first use. The slug defaults to `<failure-type>-<YYYY-MM-DD>` if not supplied as an argument.

---

## Feature 4 — Workflow Integration

### CLAUDE.md + templates/CLAUDE.md.base

In Section 3 (rules), replace the existing debugging rule:

**Before:**
```
- Always use /systematic-debugging + /debug for ANY bug
```

**After:**
```
- Always use /systematic-debugging + /debug for ANY bug encountered during execution
- Always use /forensics for post-mortem investigation of completed or abandoned sessions
```

### docs/workflows/full-dev-cycle.md + templates/workflows/full-dev-cycle.md

In the VERIFY section, after step 7 (`/gsd:verify-work`), add:

```
**If verification fails or session output is suspect:** invoke `/forensics` before
retrying. Do not re-run the phase until root cause is identified — blind retries
compound the original failure.
```

---

## Implementation Scope

| Component | Type | Change |
|-----------|------|--------|
| `skills/forensics/SKILL.md` | New | Full skill with classification, three paths, post-mortem template |
| `CLAUDE.md` | Modify | Add `/forensics` rule in Section 3 |
| `templates/CLAUDE.md.base` | Modify | Same |
| `docs/workflows/full-dev-cycle.md` | Modify | Add forensics invocation in VERIFY section |
| `templates/workflows/full-dev-cycle.md` | Modify | Same |

No new hooks. No new tests (skill is pure markdown instruction; behaviour is verified by reading the skill content).

---

## Edge Cases

- **No session log found**: Skip session log step; proceed with git history + user description only. Note absence in post-mortem.
- **No planning artifacts**: Skip `.planning/` step; note absence.
- **Forensics invoked during live execution**: Redirect to `systematic-debugging` — forensics is for post-session use only.
- **`docs/forensics/` directory absent**: Create it before writing the post-mortem.
- **Slug collision (same slug, same date)**: Append `-2`, `-3` etc.

---

*Generated: 2026-04-02 | Silver Bullet v0.2.0*
