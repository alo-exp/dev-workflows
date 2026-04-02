# Full Dev Cycle Workflow

> **ENFORCED** — Silver Bullet hooks track Skill tool invocations for quality gates
> and gap-filling skills. GSD's own hooks (workflow guard, context monitor) enforce
> GSD step compliance independently. Both enforcement layers run in parallel.
>
> Completion audit BLOCKS git commit/push/deploy if required skills are missing.
> Context monitor warns at ≤35% remaining tokens, escalates at ≤25%.

## Invocation Methods

| What | How to invoke |
|------|---------------|
| GSD workflow steps (`/gsd:*`) | Slash command — type `/gsd:new-project`, `/gsd:discuss-phase`, etc. |
| Silver Bullet skills | Skill tool — `/quality-gates`, `/code-review`, etc. |
| Gap-filling skills | Skill tool — `/testing-strategy`, `/documentation`, etc. |

Use `/gsd:next` at any point to auto-advance to the next GSD step if unsure of current state.

---

## STEP 0: SESSION MODE

> Run once at the very start of the session, before any project work.

Ask:
> Run this session **interactively** or **autonomously**?
> - **Interactive** (default) — I pause at decision points and phase gates
> - **Autonomous** — I drive start to finish, surface blockers at the end

Write choice to `/tmp/.silver-bullet-mode`:
```bash
echo "interactive" > /tmp/.silver-bullet-mode   # or "autonomous"
```

**If autonomous was chosen**, ask one follow-up before proceeding:

> Any decision points you want to pre-answer? Common ones:
> - Model routing — Planning phase: Sonnet or Opus?
> - Model routing — Design phase: Sonnet or Opus?
> - Worktree: use one for this task, or work on main?
> - Agent Teams: use worktree isolation, or main worktree throughout?
> Leave blank to use defaults (Sonnet for both phases, main, isolated).

Write answers into the `## Pre-answers` section of the session log immediately. Format each answer as:
`- Model routing — Planning: <value>`
`- Model routing — Design: <value>`
`- Worktree: <value>`
`- Agent Teams: <value>`

Omit any key the user left blank (default applies). Read pre-answers mid-session from the log
at `/tmp/.silver-bullet-session-log-path`, stripping the leading `- ` before splitting on `:`.
Log each applied pre-answer under "Autonomous decisions" with note `(pre-answered at Step 0)`.

**Fallback**: if the session log or `## Pre-answers` section is unreadable at any point,
use defaults: Sonnet for both phases, main, isolated.

---

## PROJECT INITIALIZATION

> Run once per project. Skip entirely if `.planning/PROJECT.md` already exists.

1. **Worktree** (inline decision) — Ask user: "Should I use a git worktree for this
   task?" If yes, create one before proceeding.

2. `/gsd:new-project` — Kick off with questions, ecosystem research, requirements
   scoping, and roadmap generation.
   → Produces: `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`

---

## PER-PHASE LOOP

> Repeat steps 3–12 for each phase listed in `.planning/ROADMAP.md`.
> Use `/gsd:next` to confirm which phase is current.

---

### MODEL ROUTING (once per session)

Before DISCUSS begins, ask:
> Entering Planning phase. Use Opus (claude-opus-4-6) for deeper reasoning, or stay on Sonnet?

Autonomous mode: stay Sonnet; escalate silently only on measurably incomplete planning output.

---

### SKILL DISCOVERY (once per task, before DISCUSS)

Scan installed skills from two sources:
1. `~/.claude/skills/` — flat `.md` files
2. `~/.claude/plugins/cache/` — glob `*/*/*/skills/*/SKILL.md` (layout: publisher/plugin/version/skills/skill-name)

Cross-reference the combined list against `all_tracked` in `.silver-bullet.json` and the
current task description. Surface candidates:
> Skills that may apply to this task: `/security` — auth changes; `/system-design` — new service

If no matches or both directories absent/empty: log "Skill discovery: no candidates surfaced."
Write results to `## Skills flagged at discovery` in the session log. **Do not invoke yet.**

---

### DISCUSS

3. `/gsd:discuss-phase` — Capture implementation decisions, gray areas, and
   user preferences for this specific phase before any planning begins.      **REQUIRED** ← DO NOT SKIP
   → Produces: `.planning/{phase}-CONTEXT.md`

   **Conditional sub-steps** (invoke via Skill tool if applicable):
   - If this phase introduces an **architectural decision**: write an ADR inline
     (structure: title, status, context, decision, consequences) before moving to PLAN.
   - If this phase introduces a **new service or major component**: `/system-design`
   - If this phase involves **UI work**: `/design-system` + `/ux-copy`

   **Model routing for Design**: if any design sub-steps apply (design-system, ux-copy,
   architecture, system-design), ask once before beginning them:
   > Entering Design phase. Use Opus, or stay on Sonnet?

---

### QUALITY GATES

4. `/quality-gates` — Apply all 8 Silver Bullet quality dimensions (modularity,     **REQUIRED** ← DO NOT SKIP
   reusability, scalability, security, reliability, usability, testability,
   extensibility) against the current design. Produces a consolidated pass/fail
   report. All dimensions must pass — ❌ is a hard stop, not a warning.

   **Agent Team dispatch**: Dispatch all 8 quality dimensions as a single parallel
   Agent Team wave — one agent per dimension, `isolation: "worktree"`.
   Claude synthesises results. Conflict resolution: more conservative/restrictive
   finding wins; resolution rationale logged in session log.
   Autonomous mode: all dispatches use `run_in_background: true`.

---

### PLAN

5. `/gsd:plan-phase` — Research → plan → verify plan. Quality gate report from      **REQUIRED** ← DO NOT SKIP
   step 4 feeds into the plan as hard requirements.
   → Produces: `.planning/{phase}-RESEARCH.md`, `.planning/{phase}-{N}-PLAN.md`

   **Skill gap check (post-plan):** After the plan is written, cross-reference all installed
   skills (both sources, including `all_tracked`) against the plan content. Flag any skill
   covering a concern not explicitly in the plan.
   - Interactive: ask whether to add the flagged skill
   - Autonomous: add to plan or log omission as autonomous decision
   Write results to `## Skill gap check (post-plan)` in the session log.

---

### EXECUTE

6. `/gsd:execute-phase` — Wave-based parallel execution with atomic commit per task. **REQUIRED** ← DO NOT SKIP
   TDD principles apply per task within GSD execution.
   → Produces: atomic git commits (one per task), `.planning/{phase}-{N}-SUMMARY.md`

   Each GSD wave dispatches Agent Teams for independent implementation units
   (`isolation: "worktree"` per agent). Merge gate after each wave before the next begins.
   Autonomous mode: all agents use `run_in_background: true`.

---

### VERIFY

7. `/gsd:verify-work` — Goal-backward verification against requirements + UAT.       **REQUIRED** ← DO NOT SKIP
   → Produces: `.planning/{phase}-VERIFICATION.md`, `.planning/{phase}-UAT.md`

   **If step 7 fails or output is suspect:** invoke `/forensics` before retrying.
   Identify root cause first, then re-run the failing phase from the beginning.
   Do not advance to step 8 until step 7 passes. Blind retries compound failures.

   **Agent Team scope for steps 8 + 10**: Steps 8 and 10 may use parallel agents
   (security, performance, correctness) with `isolation: "worktree"`.
   Step 9 (`/requesting-code-review`) is human-facing — runs sequentially after
   step 8 agent wave resolves; cannot be parallelised.
   Autonomous mode: agent dispatches use `run_in_background: true`.

8. `/code-review` — Peer code quality review (security, perf, correctness,           **REQUIRED** ← DO NOT SKIP
   readability — distinct from GSD's goal verification).
   `superpowers:code-reviewer` — Run code-reviewer subagent immediately after.
   **Review loop rule**: re-dispatch reviewer until it returns ✅ Approved. Max 3 iterations
   before surfacing remaining issues to user. Never stop early on "minor" issues.

9. `/requesting-code-review` — Request external or peer review.

10. `/receiving-code-review` — Triage and accept/reject all items from 8–9.          **REQUIRED** ← DO NOT SKIP

---

### POST-REVIEW EXECUTION (only if items were accepted in step 10)

11. `/gsd:plan-phase`    — Create a plan to address accepted review items.
12. `/gsd:execute-phase` — Implement the review-driven plan with atomic commits.

---

> **End of per-phase loop.** Return to step 3 for the next phase in ROADMAP.md.
> All phases must complete before moving to FINALIZATION.

---

## FINALIZATION

> Run once after all phases are complete.

13. `/testing-strategy` — Define test strategy: pyramid, coverage goals,             **REQUIRED** ← DO NOT SKIP
    test classification, tooling decisions.

14. **Tech-debt notes** (inline) — Append identified debt to `docs/tech-debt.md`.
    Format: `| Item | Severity | Effort | Phase introduced |`. Create file if needed.

15. `/documentation` — Update or create all project documentation.                   **REQUIRED** ← DO NOT SKIP
    Minimum required files:
    - `docs/Master-PRD.md`
    - `docs/Architecture-and-Design.md`
    - `docs/Testing-Strategy-and-Plan.md`
    - `docs/CICD.md`

    **Additional required at this step:**
    - Update `docs/KNOWLEDGE.md` Part 2: append dated entries to Architecture patterns,
      Known gotchas, Key decisions, Recurring patterns, Open questions as applicable.
      Resolved questions: append `[RESOLVED YYYY-MM-DD]: <resolution>` below original.
    - Update `docs/CHANGELOG.md`: prepend a new entry (newest first):
      ```
      ## YYYY-MM-DD — <task-slug>
      **What**: one sentence
      **Commits**: <hashes>
      **Skills run**: <list>
      **Virtual cost**: ~$X.XX (Model, complexity)
      **KNOWLEDGE.md**: updated (<sections>) | no changes
      ```
      Virtual cost complexity tiers: simple < 5 files / < 300 lines changed;
      medium 5–15 files or 300–1000 lines; complex > 15 files or architectural.
      Sonnet base rate; Opus ≈ 3× multiplier.
    - Complete the session log: read path from `/tmp/.silver-bullet-session-log-path`,
      edit that file to fill in Task, Approach, Files changed, Skills invoked,
      Agent Teams dispatched, Autonomous decisions, Outcome, KNOWLEDGE.md additions,
      Model, Virtual cost. If `/tmp/.silver-bullet-session-log-path` is missing,
      create `docs/sessions/<today>-manual.md` from the session log template.
    - Documentation agents writing to `docs/` run in the **main worktree only**
      (no `isolation: "worktree"`). Only implementation-touching agents use worktree isolation.

16. `/finishing-a-development-branch` — Branch rebase, cleanup, and merge prep.      **REQUIRED** ← DO NOT SKIP

---

## DEPLOYMENT

17. **CI/CD pipeline** — Use existing pipeline or set one up before deploying.       **REQUIRED** ← DO NOT SKIP
    GitHub repos: use GitHub Actions.

    **CI verification gate:**
    - Run local verify commands first (from `.silver-bullet.json` `verify_commands`,
      or stack defaults: `npm test` / `pytest` / `cargo test` / `go test ./...`)
    - Check CI: `gh run list --limit 1 --json status,conclusion`
    - **Autonomous mode**: poll every 30 seconds, up to 20 retries (10 min max).
      On timeout: log blocker under "Needs human review", surface in completion summary,
      then proceed.
    - **Interactive mode**: show status. If `in_progress`: inform user, wait for
      confirmation to re-check or proceed.
    - If CI red: log failure, invoke `/gsd:debug`.
    - **Missing ci.yml rule**: if `.github/workflows/ci.yml` is absent at this step,
      Claude must NOT invoke `/deploy-checklist`. Log as blocker under "Needs human review",
      surface missing file to user, stop deployment steps.
    - Race condition: the post-commit hook (ci-status-check.sh) reflects the last
      *completed* run, not necessarily this push. This polling loop is the authoritative gate.

18. `/deploy-checklist` — Pre-deployment verification gate.                          **REQUIRED** ← DO NOT SKIP

---

## SHIP

19. `/gsd:ship` — Create PR from verified, deployed work.                            **REQUIRED** ← DO NOT SKIP
    → Produces: pull request with phase summaries and requirement coverage.

**Autonomous completion cleanup** (run after outputting structured summary):
```bash
rm -f /tmp/.silver-bullet-timeout /tmp/.silver-bullet-sentinel-pid \
      /tmp/.silver-bullet-session-start-time /tmp/.silver-bullet-timeout-warn-count
```
This clears the timeout sentinel so `timeout-check.sh` stops warning.

---

## Review Loop Enforcement

Every review loop in this workflow (spec review, plan review, code review, verification) **MUST iterate until the reviewer returns ✅ Approved**. No exceptions.

- Never stop because "issues are minor" or "close enough"
- Never count a round as approved unless reviewer explicitly outputs `✅ Approved`
- Maximum 3 iterations before surfacing to user — but MUST reach that maximum, not stop early
- If iteration 3 still returns issues: surface the issue list to the user and wait for direction

---

## Enforcement Rules

- **GSD steps** are enforced by instruction (this file + CLAUDE.md) and GSD's own hooks.
  GSD steps MUST follow DISCUSS → QUALITY GATES → PLAN → EXECUTE → VERIFY order per phase.
- **Silver Bullet skills** (quality gates + gap-fillers) are enforced by PostToolUse hooks
  that track Skill tool invocations. "I already covered this" is NOT valid.
- Phase order is a hard constraint: do NOT start PLAN before `/quality-gates` completes.
- For ANY bug encountered during execution: use `/gsd:debug`.
- For trivial changes (typos, copy fixes, config tweaks): `touch /tmp/.silver-bullet-trivial`
