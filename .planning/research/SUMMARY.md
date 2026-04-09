# Research Summary: Silver Bullet v0.14.0

**Project:** Silver Bullet v0.14.0 — AI-Driven Spec & Multi-Repo Orchestration
**Researched:** 2026-04-09
**Confidence:** MEDIUM-HIGH

## Executive Summary

v0.14.0 adds a spec-creation layer on top of SB's mature SDLC orchestration. The pattern: delegate all external data access to MCP connectors (Atlassian, Figma, Google), build SB's contribution as orchestration-only skills (SKILL.md files, no custom API code), and anchor every downstream capability on a single canonical `.planning/SPEC.md` artifact.

## Stack Additions

| Technology | Purpose | Confidence |
|-----------|---------|------------|
| Atlassian MCP server | JIRA ticket + Confluence ingestion | MEDIUM |
| Figma MCP server (beta) | Design context + token extraction | MEDIUM |
| Google Drive MCP / Workspace CLI | Google Docs/Slides extraction | LOW |
| `gh` CLI (existing) | Cross-repo spec fetching | HIGH |

**Critical gap:** JIRA attachment content (PDFs, images) not returned by any MCP server today. Accept text fields only.
**No official Google MCP server exists.** Community options or Workspace CLI are the fallback.

## Feature Table Stakes

| Capability | Category | Reuse vs New |
|-----------|----------|-------------|
| Canonical SPEC.md format | Table stakes | NEW: templates/specs/ |
| AI-guided elicitation (Socratic dialogue) | Table stakes | NEW: silver-spec skill |
| JIRA ticket → SPEC.md draft | Table stakes | NEW: silver-ingest skill |
| Figma → DESIGN.md | Table stakes | NEW: part of silver-ingest |
| Minimum spec floor (hard block on plan-phase) | Table stakes | NEW: spec-floor-check.sh hook |
| Pre-build validation gate | Table stakes | NEW: silver-validate skill |
| PR → spec traceability | Table stakes | NEW: pr-traceability.sh hook |
| UAT gate on milestone completion | Table stakes | NEW: uat-gate.sh hook |
| Multi-repo spec fetch + version pinning | Differentiator | NEW: silver-ingest --source-url |
| Fast-path minimal spec (3-field, separate schema) | Differentiator | NEW: inline in spec-floor-check |

## Architecture Approach

**Three new skills, three new hooks, zero GSD modifications.**

### New Skills
1. `silver-ingest` — ingestion adapter: JIRA/Figma/Google Docs → SPEC.md + DESIGN.md; also handles cross-repo fetch
2. `silver-spec` — AI-guided elicitation: Socratic dialogue → SPEC.md + REQUIREMENTS.md
3. `silver-validate` — pre-build gap analysis: SPEC.md vs PLAN.md diff

### New Hooks
1. `spec-floor-check.sh` — PreToolUse on gsd-plan-phase: hard block if required sections missing; warning-only on gsd-fast
2. `pr-traceability.sh` — PostToolUse on gsd-ship: reads session record, appends to PR
3. `uat-gate.sh` — PreToolUse on gsd-complete-milestone: blocks if UAT not run or FAIL

### Cross-Repo Pattern
On-demand fetch via `gh` CLI or GitHub raw URL → `.planning/SPEC.main.md` (read-only cache). Version pinned via `spec-version:` in SPEC.md frontmatter. No git submodules (Claude Code tools don't traverse submodule boundaries).

## Critical Pitfalls

1. **Spec theater** — AI fills gaps with plausible text. Prevention: assumption-first elicitation, `[ASSUMPTION: ...]` blocks required, density is quality signal.
2. **MCP connector instability** — partial failure produces degraded spec silently. Prevention: mandatory ingestion manifest, missing = `[ARTIFACT MISSING]`, not empty.
3. **Multi-repo spec drift** — stale spec drives implementation invisibly. Prevention: version pinning + mobile-repo validation at session start.
4. **Gate as rubber stamp** — soft-report gates ignored within weeks. Prevention: hard-block vs soft-warning decided at design time.
5. **Spec floor breaks fast-path** — uniform schema defeats fast-path purpose. Prevention: separate 3-field minimal spec format.
6. **Traceability as human annotation** — unreliable from day one. Prevention: machine-generated from session records written at session start.

## Recommended Build Order

### Phase 1: Spec Foundation
Canonical SPEC.md format + templates, `silver-spec` elicitation skill, spec floor hook, fast-path minimal schema. **This is the linchpin — all other phases depend on it.**
Delivers: B, D, H, partial F.

### Phase 2: Ingestion + Multi-Repo
JIRA/Figma/Google Docs ingestion via MCP, cross-repo spec fetch with version pinning, ingestion manifest.
Delivers: A, C, E.

### Phase 3: Validation, Traceability, UAT Gate
`silver-validate` skill, PR traceability hook, UAT gate hook, calibration with real specs.
Delivers: F, G, I.

### Phase 4: Documentation Pass
Update silver-bullet.md.base with spec lifecycle section, MCP prerequisite setup, full-dev-cycle workflow updates, template parity.

## Research Flags

| Flag | Phase | Action |
|------|-------|--------|
| Google Docs MCP path undecided | Phase 2 | Decision record at planning time |
| Atlassian SSE deprecated 2026-06-30 | Phase 2 | Use `/v1/mcp` streamable HTTP |
| Gate calibration needs real specs | Phase 3 | Sub-step with 5-10 real specs before shipping |
| Figma MCP beta-to-paid timeline unknown | Phase 2 | Document dependency risk |

---
*Research completed: 2026-04-09*
*Ready for requirements: yes*
