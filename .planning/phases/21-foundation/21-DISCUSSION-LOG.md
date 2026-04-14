# Phase 21: Foundation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-14
**Phase:** 21-foundation
**Areas discussed:** Path contract location, WORKFLOW.md template pattern, Assessor architecture, doc-scheme update scope

---

## Path Contract Location

| Option | Description | Selected |
|--------|-------------|----------|
| Inline in design spec | Contracts live in the design spec §5, referenced by path implementations | ✓ |
| Separate contracts/ directory | One file per path contract | |
| Inside each skill SKILL.md | Contract embedded in implementing skill | |

**User's choice:** Inline in design spec (autonomous decision — design spec already contains all 17 contracts in full detail)
**Notes:** A derived summary doc will be generated for quick lookup.

---

## WORKFLOW.md Template Pattern

| Option | Description | Selected |
|--------|-------------|----------|
| templates/workflow.md.base | Follow existing template convention | ✓ |
| Inline in silver-bullet.md | Embed in main config template | |

**User's choice:** templates/workflow.md.base (autonomous — consistent with existing patterns)
**Notes:** FIFO truncation for 100-line cap on completed path entries.

---

## Assessor Architecture

| Option | Description | Selected |
|--------|-------------|----------|
| Standalone skill | New skills/artifact-review-assessor/SKILL.md | ✓ |
| Integrated into artifact-reviewer | Add triage to existing reviewer skill | |

**User's choice:** Standalone skill (per design spec §6)
**Notes:** Separate concerns — reviewer produces, assessor triages.

---

## doc-scheme Update Scope

| Option | Description | Selected |
|--------|-------------|----------|
| Additive only | Add 5 new artifacts + rule 6, no restructure | ✓ |
| Full restructure | Reorganize all artifact tables | |

**User's choice:** Additive only (autonomous — minimal risk, clear scope)

---

## Claude's Discretion

- File organization within assessor skill directory
- Exact formatting of contracts summary document
- Order of new artifacts in doc-scheme tables

## Deferred Ideas

None
