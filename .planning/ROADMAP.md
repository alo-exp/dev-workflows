# Roadmap — Silver Bullet v0.7.0

## Phase 1: Separate silver-bullet.md from CLAUDE.md
**Goal:** Move all Silver Bullet enforcement instructions from CLAUDE.md into a dedicated silver-bullet.md file at project root. Update /using-silver-bullet skill for fresh setup, update mode, and conflict detection. Update the plugin's own project to eat its own dogfood.

**Requirements:** [SB-R1]

**Plans:** 1 plan

Plans:
- [x] 01-PLAN.md — Create silver-bullet.md template, simplify CLAUDE.md template, update setup skill, dogfood, update help site

**Success Criteria:**
- `silver-bullet.md` exists at project root with all 10 sections (0-9)
- `CLAUDE.md` references silver-bullet.md with a mandatory enforcement line
- Update mode overwrites only silver-bullet.md, never CLAUDE.md
- Conflict detection resolves contradictions between CLAUDE.md and silver-bullet.md interactively

**Scope:**
- Create `templates/silver-bullet.md.base` with all SB content from current CLAUDE.md.base
- Simplify `templates/CLAUDE.md.base` to reference silver-bullet.md
- Update `skills/using-silver-bullet/SKILL.md` — fresh setup writes both files, update mode overwrites silver-bullet.md only, conflict detection scans CLAUDE.md
- Update plugin's own CLAUDE.md + create silver-bullet.md (dogfood)
- Update help site references and search index
