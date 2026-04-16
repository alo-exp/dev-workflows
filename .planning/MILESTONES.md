# Milestones

## v0.20.11 Trivial-Session Bypass (Shipped: 2026-04-16)

**Type:** Patch release (2 hook entries, 1 CI fix, version bump)

**Key accomplishments:**

- Added SessionStart hook to create `~/.claude/.silver-bullet/trivial` — every session starts trivial (skill gate bypassed)
- Added PostToolUse Write|Edit|MultiEdit hook to remove trivial file — gate re-arms automatically when files are modified
- Fixed CI `verify-references` step to skip inline shell commands (non-plugin-path commands like mkdir/touch/rm)
- Stop-check and ci-status-check skill gates now only fire in sessions where files were actually changed

**Release:** https://github.com/alo-exp/silver-bullet/releases/tag/v0.20.11

---

## v0.16.0 Advanced Review Intelligence (Shipped: 2026-04-09)

**Phases completed:** 3 phases, 4 plans, 2 tasks

**Key accomplishments:**

- config.json schema:
- One-liner:
- One-liner:
- Cross-artifact reviewer with 3 QC checks detecting unmapped ACs, orphaned requirements, and phantom phase entries — registered in artifact-reviewer framework for auto-dispatch

---
