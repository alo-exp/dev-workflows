# Quick Task 260408-ota Summary

**Task:** Add auto-update check to Session Start §0
**Completed:** 2026-04-08
**Commit:** ae19c87
**Status:** ✅ Verified

## What Was Built

Added step 5 to `## 0. Session Startup` in both `silver-bullet.md` and `templates/silver-bullet.md.base`.

**Step 5.1 — Silver Bullet:** reads installed version from `installed_plugins.json`, checks latest from GitHub releases API, offers A/B AskUserQuestion to run `/silver:update` or skip. Graceful fallback on offline/error.

**Step 5.2 — GSD:** reads `~/.claude/get-shit-done/VERSION`, checks latest via `npm view get-shit-done-cc version`, offers A/B AskUserQuestion to run `/gsd-update` or skip. Graceful fallback on unknown version.

**Step 5.3 — Plugins (informational):** reads Superpowers/Design/Engineering installed versions from plugin registry, displays them, provides manual `/plugin install` update instructions. No prompt — proceeds immediately.

Step 5 is inserted between step 4 ("Switch back to original model") and the Anti-Skip blockquote, so it runs after `/compact` and before any work begins.

Both `silver-bullet.md` (live) and `templates/silver-bullet.md.base` (source of truth for `/silver:init --update`) are in sync.

## Verification Evidence

- `grep -c "Check for updates" silver-bullet.md` → **1** ✅
- `grep -c "Check for updates" templates/silver-bullet.md.base` → **1** ✅
- Step order: 1→2→3→4→5→Anti-Skip (lines 14–56) ✅
- `grep -c "silver:update\|gsd-update" silver-bullet.md` → **2** ✅
