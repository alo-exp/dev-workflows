# Silver Bullet — Autonomous Mode Hardening Design

**Date:** 2026-04-02
**Scope:** Group A gap-narrowing — answer injection, timeout supervision, skill auto-discovery
**Out of scope:** Group B (semantic context compression, captures system, forensics skill)
**Reference:** `docs/gsd2-vs-sb-gap-analysis.md` (Categories 1, 6, 10 partial)
**Target workflow:** `docs/workflows/full-dev-cycle.md`

---

## Architecture: Hybrid Hook + Workflow

Same layer split as Round 1:

| Layer | Handles |
|-------|---------|
| **Hook (PostToolUse/session-log-init extension)** | Background timeout sentinel launch, per-tool-use timeout flag check |
| **Workflow + CLAUDE.md** | Answer injection at Step 0, enhanced anti-stall rules, skill auto-discovery at two workflow points |

---

## Feature 1 — Answer Injection

### Mechanism

Step 0 (session mode prompt) is extended. After the user chooses "autonomous", Claude asks one follow-up:

> Any decision points you want to pre-answer? Common ones:
> - Model routing: Sonnet or Opus for Planning/Design phases?
> - Worktree: use one for this task, or work on main?
> - Agent Teams: use worktree isolation, or main worktree throughout?
> Leave blank to use defaults (Sonnet, main, isolated).

### Storage

Answers are written into the session log under a new **"Pre-answers"** section at Step 0 (by Claude, not the hook). Format:

```markdown
## Pre-answers
- Model routing: Opus for Planning
- Worktree: main
- Agent Teams: isolated
```

### Application

Whenever a pre-answered decision point arises during the session, Claude applies the stored answer silently — no pause, no re-prompt. The decision is logged under "Autonomous decisions" with the note `(pre-answered)`.

### Scope constraint

Only the three decision points above are pre-answerable. This deliberately does not attempt to anticipate arbitrary questions — that scope belongs to the captures system (Group B).

### Fallback

If the session log is missing or the "Pre-answers" section is absent mid-session, Claude falls back to workflow defaults: Sonnet, main, isolated.

---

## Feature 2 — Timeout Supervision

### Two complementary mechanisms

#### 2a — Background sentinel (hook layer)

`hooks/session-log-init.sh` already fires when Claude writes to `/tmp/.silver-bullet-mode`. In autonomous mode, it additionally launches a background watchdog process:

```bash
(sleep 600 && echo "TIMEOUT" > /tmp/.silver-bullet-timeout) &
```

- 10-minute wall-clock timer (600 seconds)
- Writes flag file `/tmp/.silver-bullet-timeout` on expiry
- Runs as a detached background process; does not block Claude

**New hook: `hooks/timeout-check.sh`**

- Matcher: `.*` (fires on every tool use), async: true
- Checks for `/tmp/.silver-bullet-timeout`
- If flag exists: emits `hookSpecificOutput` warning banner:
  `⚠️ Autonomous session running 10+ min. Check for stalls or log a blocker.`
- Non-blocking — Claude decides whether to surface a blocker or continue
- Warning fires on every subsequent tool use until the flag is cleared

**Flag cleanup:** The flag is cleared when:
- Claude writes the autonomous completion summary (same `.silver-bullet-mode` pattern, handled by session-log-init)
- Or manually: `rm /tmp/.silver-bullet-timeout`

**Test override:** `TIMEOUT_FLAG_OVERRIDE` env var allows tests to inject a pre-written flag file path, bypassing the actual timer.

#### 2b — Enhanced anti-stall (CLAUDE.md layer)

Adds a third stall trigger to the existing two in CLAUDE.md autonomous mode rules:

**Existing triggers:**
1. Same tool call with identical args producing the same result 2+ times consecutively
2. 3+ tool calls in one step with no new state change

**New trigger (per-step budget):**
3. A single workflow step accumulates **more than 10 tool calls** with no new file written, no new decision logged, and no new information surfaced

On any stall trigger: make best-judgment decision, move on, log under "Autonomous decisions."

---

## Feature 3 — Skill Auto-Discovery

### Two insertion points

#### Point 1 — Proactive (before DISCUSS)

After the model routing prompt and before `/gsd:discuss-phase`, Claude:

1. Reads `all_tracked` from `.silver-bullet.json`
2. Scans `~/.claude/skills/` for any skills not in `all_tracked`
3. Cross-references the combined list against the current task description
4. Surfaces a short candidate list in the session:
   > Skills that may apply to this task: `/security` — task involves auth changes; `/system-design` — new service boundary detected

This list is appended to the session log under **"Skills flagged at discovery"**.

No skill is invoked at this point — awareness only.

#### Point 2 — Reactive (after plan is written)

After Step 5 (`/gsd:plan-phase`) produces `.planning/{phase}-PLAN.md`, Claude:

1. Reads the plan
2. Cross-references against all installed skills
3. Flags any skill that covers a concern the plan doesn't explicitly invoke

**If a gap is found:**
- **Interactive mode**: Claude flags it and asks whether to add the skill to the plan
- **Autonomous mode**: Claude either adds the skill to the plan or logs the omission as an autonomous decision

**Format for session log:**

```markdown
## Skills flagged at discovery
- `/security` — auth changes detected in task description
- `/system-design` — new service boundary

## Skill gap check (post-plan)
- Gap: `/security` not in plan despite auth changes → added to plan (autonomous decision)
```

---

## Implementation Scope

| Component | Type | Feature |
|-----------|------|---------|
| `hooks/session-log-init.sh` | Modify | Launch background sentinel in autonomous mode |
| `hooks/timeout-check.sh` | New hook | Check `/tmp/.silver-bullet-timeout` on every tool use |
| `tests/hooks/test-timeout-check.sh` | New test | Verify flag detection, silence on no flag, unrelated tool silence |
| `hooks/hooks.json` | Modify | Add timeout-check entry (matcher: `.*`, async: true) |
| `templates/CLAUDE.md.base` | Modify | Add per-step budget stall trigger (10 tool calls) |
| `CLAUDE.md` | Modify | Same per-step budget stall trigger |
| `templates/workflows/full-dev-cycle.md` | Modify | Step 0 answer injection Q&A; skill discovery at DISCUSS + post-plan |
| `docs/workflows/full-dev-cycle.md` | Modify | Same workflow edits applied to installed copy |

---

## Edge Cases

- **Two autonomous sessions same day**: The dedup guard in `session-log-init.sh` means only one session log exists. The timeout flag and sentinel process are session-scoped (per `/tmp/` lifetime) — no collision.
- **Interactive mode**: Sentinel is NOT launched. `timeout-check.sh` fires but exits immediately if mode is interactive (reads `/tmp/.silver-bullet-mode`).
- **Sentinel process orphaned**: If Claude Code closes before the 10-minute mark, the background `sleep` process continues but writes to `/tmp/` which is ephemeral. No persistent side effect.
- **Skill scan returns empty**: If `~/.claude/skills/` is absent or `all_tracked` is empty, discovery step emits nothing and logs "No skills available for discovery check."

---

*Generated: 2026-04-02 | Silver Bullet v0.2.0*
