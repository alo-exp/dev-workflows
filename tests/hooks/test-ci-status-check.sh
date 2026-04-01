#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK="$SCRIPT_DIR/../../hooks/ci-status-check.sh"

run_hook() {
  local cmd="$1"
  local gh_output="$2"
  printf '{"tool_name":"Bash","tool_input":{"command":"%s"}}' "$cmd" \
    | GH_STATUS_OVERRIDE="$gh_output" bash "$HOOK"
}

# Test 1: git commit + failed CI — must emit warning
out=$(run_hook "git commit -m test" '{"status":"completed","conclusion":"failure"}')
if printf '%s' "$out" | grep -q "CI"; then
  printf 'PASS: failed CI emits warning\n'
else
  printf 'FAIL: expected CI warning, got: %s\n' "$out"
  exit 1
fi

# Test 2: git commit + passing CI — must be silent
out=$(run_hook "git commit -m test" '{"status":"completed","conclusion":"success"}')
if [[ -z "$out" ]]; then
  printf 'PASS: passing CI is silent\n'
else
  printf 'FAIL: expected silence, got: %s\n' "$out"
  exit 1
fi

# Test 3: unrelated command + failed CI — must be silent
out=$(run_hook "npm install" '{"status":"completed","conclusion":"failure"}')
if [[ -z "$out" ]]; then
  printf 'PASS: unrelated command ignored\n'
else
  printf 'FAIL: expected silence, got: %s\n' "$out"
  exit 1
fi

printf 'All tests passed.\n'
