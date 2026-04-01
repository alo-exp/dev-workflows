#!/usr/bin/env bash
set -euo pipefail

# PostToolUse hook (matcher: Bash)
# Fires when Claude writes the session mode to /tmp/.silver-bullet-mode.
# Creates docs/sessions/<date>-<timestamp>.md skeleton and records path to
# /tmp/.silver-bullet-session-log-path so Step 15 (documentation) can fill it in.
# Note: hook infers mode by checking for "autonomous" in the command string.
# Known edge case: two-step writes (touch then echo) may fire the hook twice —
# dedup guard prevents a second session log.

command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')
[[ -z "$cmd" ]] && exit 0

# Only fire when command touches .silver-bullet-mode
printf '%s' "$cmd" | grep -q '\.silver-bullet-mode' || exit 0

# --- Locate project root (allow override for testing) ---
project_root="${PROJECT_ROOT_OVERRIDE:-}"
if [[ -z "$project_root" ]]; then
  search_dir="$PWD"
  while true; do
    if [[ -f "$search_dir/.silver-bullet.json" ]]; then
      project_root="$search_dir"
      break
    fi
    [[ -d "$search_dir/.git" ]] || [[ "$search_dir" == "/" ]] && break
    search_dir=$(dirname "$search_dir")
  done
fi
[[ -z "$project_root" ]] && exit 0

# Allow sessions dir override for testing
sessions_dir="${SESSION_LOG_TEST_DIR:-$project_root/docs/sessions}"
mkdir -p "$sessions_dir"

# --- Dedup: one session log per calendar day ---
today=$(date '+%Y-%m-%d')
existing=$(ls "$sessions_dir/${today}"*.md 2>/dev/null | head -1 || true)
if [[ -n "$existing" ]]; then
  printf '%s' "$existing" > /tmp/.silver-bullet-session-log-path
  printf '{"hookSpecificOutput":{"message":"ℹ️ Session log already exists: %s"}}' \
    "$(basename "$existing")"
  exit 0
fi

# --- Extract mode from command ---
mode="interactive"
printf '%s' "$cmd" | grep -q "autonomous" && mode="autonomous"

# --- Create session log ---
timestamp=$(date '+%H-%M-%S')
log_file="$sessions_dir/${today}-${timestamp}.md"

cat > "$log_file" << LOGEOF
# Session Log — ${today}

**Date:** ${today}
**Mode:** ${mode}
**Model:** (filled at step 15)
**Virtual cost:** (filled at step 15)

---

## Task

(filled at step 15)

## Approach

(filled at step 15)

## Files changed

(filled at step 15)

## Skills invoked

(filled at step 15)

## Agent Teams dispatched

(filled at step 15)

## Autonomous decisions

(none)

## Needs human review

(none)

## Outcome

(filled at step 15)

## KNOWLEDGE.md additions

(filled at step 15)
LOGEOF

printf '%s' "$log_file" > /tmp/.silver-bullet-session-log-path
printf '{"hookSpecificOutput":{"message":"📋 Session log created: docs/sessions/%s"}}' \
  "$(basename "$log_file")"
