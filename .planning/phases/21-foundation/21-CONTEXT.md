# Phase 21: Foundation - Context

**Gathered:** 2026-04-14
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver the 4 foundational building blocks for the composable paths architecture: path contract schema, WORKFLOW.md specification, artifact-review-assessor skill, and doc-scheme.md.base update. No path implementation in this phase -- contracts and infrastructure only.

</domain>

<decisions>
## Implementation Decisions

### Path Contract Schema (FOUND-01)
- **D-01:** Path contracts are documented inline within each path's section in the design spec (`docs/superpowers/specs/2026-04-14-composable-paths-design.md` §5). No separate contracts directory -- the spec IS the contract reference. Phase 22-24 will implement paths referencing this spec.
- **D-02:** The canonical contract template (§3) defines 7 required fields: Prerequisites, Trigger, Steps, Produces, Review Cycle, GSD Impact, Exit Condition. All 17 paths in the design spec already follow this schema.
- **D-03:** A summary reference document `docs/composable-paths-contracts.md` will be generated from the spec for quick lookup during implementation phases. This is derived (not source-of-truth).

### WORKFLOW.md Specification (FOUND-02)
- **D-04:** WORKFLOW.md template goes in `templates/workflow.md.base` -- follows existing template pattern (silver-bullet.md.base, doc-scheme.md.base, CLAUDE.md.base).
- **D-05:** 100-line cap enforcement: truncation strategy is FIFO on completed paths in the Path Log table. When approaching 100 lines, oldest completed entries are collapsed to a summary line: `| 1-3 | BOOTSTRAP→ORIENT→PLAN | complete | (see phase dirs) | — |`
- **D-06:** WORKFLOW.md is created by /silver composer (Phase 25) and updated by the supervision loop. Phase 21 only defines the spec/template -- no runtime creation logic.
- **D-07:** GSD isolation rule enforced: GSD never reads WORKFLOW.md. SB never writes STATE.md directly.

### artifact-review-assessor (FOUND-03)
- **D-08:** New standalone skill at `skills/artifact-review-assessor/SKILL.md`. NOT integrated into existing `skills/artifact-reviewer/` -- separate concern (reviewer produces findings, assessor triages them).
- **D-09:** Invocation chain: artifact-reviewer → artifact-review-assessor → fix MUST-FIX only → re-review → repeat until 2 consecutive clean passes.
- **D-10:** Assessor judges against artifact CONTRACT (per §6 contract sources table). Three classifications: MUST-FIX (contract violation), NICE-TO-HAVE (logged to WORKFLOW.md deferred improvements), DISMISS (extraneous).
- **D-11:** No review loop on the assessor itself. Assessor triages once per reviewer invocation.
- **D-12:** Assessor receives reviewer findings as input (REVIEW findings markdown), plus the artifact being reviewed and its contract source. Returns classified findings list.

### doc-scheme.md.base Update (FOUND-04)
- **D-13:** Add new artifacts to existing tables: WORKFLOW.md, VALIDATION.md, UI-SPEC.md, UI-REVIEW.md, SECURITY.md. Minimal table additions, not a restructure.
- **D-14:** Add non-redundancy rule 6: WORKFLOW.md vs STATE.md separation (WORKFLOW.md tracks composition state, STATE.md tracks GSD execution state -- never cross-write directly).
- **D-15:** No restructuring of existing artifact tables -- additive changes only.

### Claude's Discretion
- File organization within skills/artifact-review-assessor/ (single SKILL.md vs multiple support files)
- Exact wording and formatting of the contracts summary document
- Order of artifact additions in doc-scheme tables

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Design Specification
- `docs/superpowers/specs/2026-04-14-composable-paths-design.md` — Complete composable paths architecture. §3 (path contract schema), §4 (WORKFLOW.md spec), §5 (17 path definitions), §6 (artifact-review-assessor)

### Existing Templates
- `templates/doc-scheme.md.base` — Current artifact documentation scheme (to be updated)
- `templates/silver-bullet.md.base` — Main SB configuration template (context for artifact rules)

### Existing Review Infrastructure
- `skills/artifact-reviewer/SKILL.md` — Existing artifact reviewer skill (assessor works downstream of this)
- `skills/review-context/SKILL.md` — Example of existing artifact-specific reviewer

### Requirements
- `.planning/REQUIREMENTS.md` — FOUND-01 through FOUND-04

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `skills/artifact-reviewer/` — Existing reviewer infrastructure; assessor will follow similar SKILL.md pattern
- `templates/doc-scheme.md.base` — Existing artifact tables to extend
- All `skills/review-*/SKILL.md` files — Contract sources for the assessor's artifact contract table

### Established Patterns
- Skills are single SKILL.md files in `skills/{skill-name}/` directories
- Templates use `.base` suffix and live in `templates/`
- Doc-scheme uses markdown tables for artifact documentation

### Integration Points
- artifact-review-assessor sits between artifact-reviewer output and fix-commit cycle
- WORKFLOW.md template will be used by /silver composer (Phase 25)
- doc-scheme.md.base update affects `silver-bullet.md.base` §2 artifact tables

</code_context>

<specifics>
## Specific Ideas

- Design spec §6 contract sources table is the definitive list of artifact→contract mappings (11 artifacts)
- WORKFLOW.md template in §4 has exact markdown format including all 6 sections (Composition, Path Log, Phase Iterations, Dynamic Insertions, Autonomous Decisions, Deferred Improvements, Next Path)
- Assessor must NOT have a review loop on itself (explicit design decision from brainstorming)

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 21-foundation*
*Context gathered: 2026-04-14*
