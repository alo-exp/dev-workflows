#!/usr/bin/env bash
set -euo pipefail

# PostToolUse hook (matcher: Bash)
# After git commit/push, checks last completed CI run status and warns if failed.
# NON-BLOCKING — warning only. Step 17 polling loop is the authoritative gate.
# Race condition: reflects most recently COMPLETED run, not necessarily this push.

command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""') || true
[[ -z "$cmd" ]] && exit 0

# Only fire on commit or push
printf '%s' "$cmd" | grep -qE '\bgit (commit|push)\b' || exit 0

# gh CLI required for real runs; test override bypasses it
if [[ -n "${GH_STATUS_OVERRIDE:-}" ]]; then
  run_json="$GH_STATUS_OVERRIDE"
else
  command -v gh >/dev/null 2>&1 || exit 0
  run_json=$(gh run list --limit 1 --json status,conclusion 2>/dev/null \
    | jq -r '.[0] // empty' 2>/dev/null) || true
fi

[[ -z "${run_json:-}" ]] && exit 0

conclusion=$(printf '%s' "$run_json" | jq -r '.conclusion // ""' 2>/dev/null) || true
status=$(printf '%s' "$run_json" | jq -r '.status // ""' 2>/dev/null) || true

if [[ "$conclusion" == "failure" ]] || [[ "$conclusion" == "cancelled" ]]; then
  printf '{"hookSpecificOutput":{"message":"⚠️ CI WARNING: Last completed run conclusion=%s. Check before deploying. (Step 17 polling is the authoritative gate.)"}}' \
    "$conclusion"
elif [[ "$status" == "in_progress" ]]; then
  printf '{"hookSpecificOutput":{"message":"ℹ️ CI in progress. Step 17 will poll for result."}}'
fi
# success or unknown: silent exit
