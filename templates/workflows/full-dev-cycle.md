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

### DISCUSS

3. `/gsd:discuss-phase` — Capture implementation decisions, gray areas, and
   user preferences for this specific phase before any planning begins.      **REQUIRED** ← DO NOT SKIP
   → Produces: `.planning/{phase}-CONTEXT.md`

   **Conditional sub-steps** (invoke via Skill tool if applicable):
   - If this phase introduces an **architectural decision**: write an ADR inline
     (structure: title, status, context, decision, consequences) before moving to PLAN.
   - If this phase introduces a **new service or major component**: `/system-design`
   - If this phase involves **UI work**: `/design-system` + `/ux-copy`

---

### QUALITY GATES

4. `/quality-gates` — Apply all 8 Silver Bullet quality dimensions (modularity,     **REQUIRED** ← DO NOT SKIP
   reusability, scalability, security, reliability, usability, testability,
   extensibility) against the current design. Produces a consolidated pass/fail
   report. All dimensions must pass — ❌ is a hard stop, not a warning.

---

### PLAN

5. `/gsd:plan-phase` — Research → plan → verify plan. Quality gate report from      **REQUIRED** ← DO NOT SKIP
   step 4 feeds into the plan as hard requirements.
   → Produces: `.planning/{phase}-RESEARCH.md`, `.planning/{phase}-{N}-PLAN.md`

---

### EXECUTE

6. `/gsd:execute-phase` — Wave-based parallel execution with atomic commit per task. **REQUIRED** ← DO NOT SKIP
   TDD principles apply per task within GSD execution.
   → Produces: atomic git commits (one per task), `.planning/{phase}-{N}-SUMMARY.md`

---

### VERIFY

7. `/gsd:verify-work` — Goal-backward verification against requirements + UAT.       **REQUIRED** ← DO NOT SKIP
   → Produces: `.planning/{phase}-VERIFICATION.md`, `.planning/{phase}-UAT.md`

8. `/code-review` — Peer code quality review (security, perf, correctness,           **REQUIRED** ← DO NOT SKIP
   readability — distinct from GSD's goal verification).
   `superpowers:code-reviewer` — Run code-reviewer subagent immediately after.

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

16. `/finishing-a-development-branch` — Branch rebase, cleanup, and merge prep.      **REQUIRED** ← DO NOT SKIP

---

## DEPLOYMENT

17. **CI/CD pipeline** — Use existing pipeline or set one up before deploying.       **REQUIRED** ← DO NOT SKIP
    GitHub repos: use GitHub Actions.

18. `/deploy-checklist` — Pre-deployment verification gate.                          **REQUIRED** ← DO NOT SKIP

---

## SHIP

19. `/gsd:ship` — Create PR from verified, deployed work.                            **REQUIRED** ← DO NOT SKIP
    → Produces: pull request with phase summaries and requirement coverage.

---

## Enforcement Rules

- **GSD steps** are enforced by instruction (this file + CLAUDE.md) and GSD's own hooks.
  GSD steps MUST follow DISCUSS → QUALITY GATES → PLAN → EXECUTE → VERIFY order per phase.
- **Silver Bullet skills** (quality gates + gap-fillers) are enforced by PostToolUse hooks
  that track Skill tool invocations. "I already covered this" is NOT valid.
- Phase order is a hard constraint: do NOT start PLAN before `/quality-gates` completes.
- For ANY bug encountered during execution: use `/gsd:debug`.
- For trivial changes (typos, copy fixes, config tweaks): `touch /tmp/.silver-bullet-trivial`
