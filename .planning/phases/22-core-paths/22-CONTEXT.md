# Phase 22: Core Paths - Context

**Gathered:** 2026-04-14
**Status:** Ready for planning
**Source:** Auto-mode (decisions from design spec + Phase 21 prior context)

<domain>
## Phase Boundary

Implement the 6 core paths that form the backbone of every composition: PATH 0 (BOOTSTRAP), PATH 1 (ORIENT), PATH 5 (PLAN), PATH 7 (EXECUTE), PATH 11 (VERIFY), PATH 13 (SHIP). Each path is implemented as a section within the silver-* skill files that will invoke it. This phase does NOT implement the /silver composer (Phase 25) — it implements the path definitions that the composer will chain.

</domain>

<decisions>
## Implementation Decisions

### Path Implementation Strategy
- **D-01:** Each path is implemented by updating the corresponding silver-* skill file (silver-feature, silver-bugfix, silver-ui, etc.) to follow the path contract from `docs/composable-paths-contracts.md`. The paths are NOT separate standalone files — they are the step sequences within existing silver-* workflows.
- **D-02:** Forward-compatible building: paths work under current hook enforcement. No hook changes until Phase 26.
- **D-03:** Path contracts from Phase 21 (`docs/composable-paths-contracts.md`) are the reference. Design spec §5 is the source of truth for step details.

### PATH 0: BOOTSTRAP
- **D-04:** PATH 0 wraps existing skills: episodic-memory, gsd-new-project, gsd-map-codebase, gsd-new-milestone, gsd-resume-work, gsd-progress. All are as-needed conditional steps. Review cycle: ROADMAP.md + REQUIREMENTS.md through artifact-review-assessor.
- **D-05:** Exit condition: STATE.md exists with valid Current Position. No new skills needed — PATH 0 orchestrates existing ones.

### PATH 1: ORIENT
- **D-06:** PATH 1 wraps: gsd-intel (always), gsd-scan (as-needed), gsd-map-codebase (as-needed). Prerequisite: PATH 0 completed (STATE.md exists). No review cycle.

### PATH 5: PLAN
- **D-07:** PATH 5 step order: gsd-discuss-phase → writing-plans → testing-strategy → list-phase-assumptions → analyze-dependencies → gsd-plan-phase. Review cycle for CONTEXT.md, RESEARCH.md, PLAN.md through assessor.
- **D-08:** Exit condition: PLAN.md exists with plan-checker PASS (2 consecutive clean passes).

### PATH 7: EXECUTE
- **D-09:** PATH 7 uses gsd-execute-phase OR gsd-autonomous as sole execution engine. TDD (superpowers:test-driven-development) is as-needed for implementation plans only. All 10 GSD assumptions preserved.
- **D-10:** Failure path: PATH 14 (DEBUG) inserted dynamically on execution failure (implemented in Phase 24).
- **D-11:** context7 available as ambient tool during execution.

### PATH 11: VERIFY
- **D-12:** PATH 11 is NON-SKIPPABLE. Steps: gsd-verify-work (always), gsd-add-tests (as-needed for coverage gaps), verification-before-completion (always). Review cycle: UAT.md through assessor.
- **D-13:** Exit condition: VERIFICATION.md with status: passed (2 consecutive clean passes).

### PATH 13: SHIP
- **D-14:** PATH 13 steps: gsd-pr-branch (as-needed), deploy-checklist (as-needed), gsd-ship (always). Prerequisites: PATH 12 pre-ship passed, PATH 11 completed.
- **D-15:** Exit condition: PR created, CI green.

### Claude's Discretion
- Internal helper functions within skill files for path prerequisite checking
- Exact error messages when prerequisites are not met
- Logging format for path entry/exit

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Path Contracts
- `docs/composable-paths-contracts.md` — Quick-lookup reference for all 18 path contracts (7 fields each)
- `docs/superpowers/specs/2026-04-14-composable-paths-design.md` §5 — Source of truth for path definitions

### Existing Skill Files (to be updated)
- `skills/silver-feature/SKILL.md` — Primary workflow that chains most paths
- `skills/silver-bugfix/SKILL.md` — Bugfix workflow
- `skills/silver/SKILL.md` — Router/composer (read for context, modified in Phase 25)

### Phase 21 Artifacts
- `templates/workflow.md.base` — WORKFLOW.md template (paths reference this format)
- `skills/artifact-review-assessor/SKILL.md` — Assessor used in review cycles
- `templates/doc-scheme.md.base` — Updated artifact documentation

### GSD Reference
- `.planning/STATE.md` — State format that paths read/write via GSD
- `.planning/ROADMAP.md` — Roadmap format for phase tracking

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `skills/silver-feature/SKILL.md` — Already implements most of the PATH 5→7→11→13 sequence, but as a fixed pipeline. Needs restructuring into composable path invocations.
- `skills/silver-bugfix/SKILL.md` — Has a simpler sequence that maps to PATH 0?→1→14→5→7→9→10→11→12→13.
- `skills/artifact-review-assessor/SKILL.md` — New from Phase 21, used in review cycles.
- `docs/composable-paths-contracts.md` — New from Phase 21, reference for path contracts.

### Established Patterns
- Skills invoke other skills via `Skill(skill="skill-name", args="...")` tool
- Step-skip protocol: explain, offer alternatives, record permanent skips in §10b
- Non-skippable gates: security, quality-gates pre-ship, gsd-verify-work

### Integration Points
- Each path checks prerequisites on entry (artifact existence checks)
- GSD skills manage STATE.md internally — paths never write STATE.md directly
- Review cycles use artifact-reviewer → artifact-review-assessor → fix → 2-pass pattern

</code_context>

<specifics>
## Specific Ideas

- PATH 0 and PATH 1 are primarily orchestration — they invoke existing GSD commands in sequence with prerequisite checks
- PATH 5 already largely exists in silver-feature steps 1c through 6 — needs restructuring to follow path contract
- PATH 7 is mostly gsd-execute-phase with TDD gate — already exists in silver-feature step 7/7a
- PATH 11 and 13 already exist in silver-feature steps 8-15 — need refactoring into path structure
- The key transformation is from a flat step list to prerequisite-checked, exit-condition-verified path units

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 22-core-paths*
*Context gathered: 2026-04-14 via auto mode*
