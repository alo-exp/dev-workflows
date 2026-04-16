---
spec-version: n/a (patch release — no SPEC.md)
uat-date: 2026-04-16
milestone: v0.20.11
---

# UAT Checklist — v0.20.11 trivial-session bypass

| # | Criterion | Result | Evidence |
|---|-----------|--------|----------|
| 1 | `hooks/hooks.json` SessionStart entry creates `~/.claude/.silver-bullet/trivial` | PASS | Verified in hooks.json — entry present, tested in session |
| 2 | `hooks/hooks.json` PostToolUse Write\|Edit\|MultiEdit entry removes `~/.claude/.silver-bullet/trivial` | PASS | Verified in hooks.json — entry present, file removed on first edit this session |
| 3 | `stop-check.sh` trivial bypass exits 0 when file exists and is not a symlink | PASS | Read stop-check.sh lines 56-60 — logic unchanged and correct |
| 4 | `ci-status-check.sh` trivial bypass exits 0 when file exists and is not a symlink | PASS | Read ci-status-check.sh lines 55-60 — same bypass logic present |
| 5 | `.claude-plugin/plugin.json` version is `0.20.11` | PASS | Confirmed via Read — version field = "0.20.11" |
| 6 | CI passes on main with new hooks.json entries | PASS | Run 24500144468 — conclusion: success |
| 7 | GitHub Release v0.20.11 published | PASS | https://github.com/alo-exp/silver-bullet/releases/tag/v0.20.11 |

## Summary

| Total | Passed | Failed | Not-Run |
|-------|--------|--------|---------|
| 7 | 7 | 0 | 0 |
