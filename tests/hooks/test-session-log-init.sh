#!/usr/bin/env bash
set -euo pipefail
# Test driver for hooks/session-log-init.sh
# Uses PROJECT_ROOT_OVERRIDE to bypass the .silver-bullet.json walk-up.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK="$SCRIPT_DIR/../../hooks/session-log-init.sh"
SESSION_LOG_DIR="/tmp/sb-test-sessions-$$"
mkdir -p "$SESSION_LOG_DIR"

run_hook() {
  local cmd="$1"
  printf '{"tool_name":"Bash","tool_input":{"command":"%s"}}' "$cmd" \
    | PROJECT_ROOT_OVERRIDE="$(dirname "$SESSION_LOG_DIR")" \
      SESSION_LOG_TEST_DIR="$SESSION_LOG_DIR" \
      bash "$HOOK"
}

# Test 1: mode file write — should create session log and emit path message
out=$(run_hook "echo autonomous > /tmp/.silver-bullet-mode")
if printf '%s' "$out" | grep -q "session"; then
  printf 'PASS: mode write triggers session log creation\n'
else
  printf 'FAIL: expected session in output, got: %s\n' "$out"
  exit 1
fi

# Test 2: unrelated command — must be silent
out=$(run_hook "git status")
if [[ -z "$out" ]]; then
  printf 'PASS: unrelated command silently ignored\n'
else
  printf 'FAIL: expected silence, got: %s\n' "$out"
  exit 1
fi

# Test 3: dedup — second trigger same day must NOT create a second file
run_hook "echo interactive > /tmp/.silver-bullet-mode" > /dev/null 2>&1 || true
file_count=$(ls "$SESSION_LOG_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
if [[ "$file_count" -eq 1 ]]; then
  printf 'PASS: dedup guard prevents second session log\n'
else
  printf 'FAIL: expected 1 session log, found: %s\n' "$file_count"
  exit 1
fi

rm -rf "$SESSION_LOG_DIR"
printf 'All tests passed.\n'
