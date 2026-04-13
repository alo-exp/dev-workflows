#!/usr/bin/env bash
# Shared helpers for live AI E2E tests
# These tests invoke real claude CLI with stored credentials.
# Each invocation costs ~$0.01-0.05.

set -euo pipefail

SB_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CLAUDE_BIN="/Users/shafqat/.local/bin/claude"
MAX_BUDGET="0.20"
PASS=0
FAIL=0
TEST_RUN_ID="$$"

# Paths set by live_setup
WORK_DIR=""
TMPSTATE=""
TMPTRIVIAL=""

live_setup() {
  WORK_DIR=$(mktemp -d)
  TMPSTATE="${HOME}/.claude/.silver-bullet/live-test-state-${TEST_RUN_ID}"
  TMPTRIVIAL="${HOME}/.claude/.silver-bullet/live-test-trivial-${TEST_RUN_ID}"

  # Remove any leftover temp state files
  rm -f "$TMPSTATE" "$TMPTRIVIAL"

  # Initialize git repo in workspace
  git -C "$WORK_DIR" init -q
  git -C "$WORK_DIR" config user.email "live-test@silver-bullet.test"
  git -C "$WORK_DIR" config user.name "Live Test"
  touch "$WORK_DIR/.gitkeep"
  git -C "$WORK_DIR" add .gitkeep
  git -C "$WORK_DIR" commit -q -m "init"
  git -C "$WORK_DIR" checkout -q -b feature/live-test

  # Copy test-app src into workspace
  if [[ -d "${SB_ROOT}/tests/test-app/src" ]]; then
    cp -r "${SB_ROOT}/tests/test-app/src" "${WORK_DIR}/src"
  else
    mkdir -p "${WORK_DIR}/src"
    echo "// placeholder" > "${WORK_DIR}/src/index.js"
  fi

  # Write .silver-bullet.json with actual state paths
  cat > "${WORK_DIR}/.silver-bullet.json" << EOJSON
{
  "project": {"name":"live-test","src_pattern":"/src/","src_exclude_pattern":"__tests__|\\\\.test\\\\.","active_workflow":"full-dev-cycle"},
  "skills": {
    "required_planning": ["quality-gates"],
    "required_deploy": ["quality-gates","code-review","requesting-code-review","receiving-code-review","testing-strategy","documentation","finishing-a-development-branch","deploy-checklist","create-release","verification-before-completion","test-driven-development","tech-debt"],
    "all_tracked": ["quality-gates","code-review","requesting-code-review","receiving-code-review","testing-strategy","documentation","finishing-a-development-branch","deploy-checklist","create-release","verification-before-completion","test-driven-development","tech-debt"]
  },
  "state": {"state_file":"${TMPSTATE}","trivial_file":"${TMPTRIVIAL}"}
}
EOJSON

  # Commit the config
  git -C "$WORK_DIR" add -A
  git -C "$WORK_DIR" commit -q -m "setup"

  # Export env override for hooks
  export SILVER_BULLET_STATE_FILE="$TMPSTATE"
}

live_teardown() {
  rm -rf "$WORK_DIR"
  rm -f "$TMPSTATE" "$TMPTRIVIAL"
  rm -f "${HOME}/.claude/.silver-bullet/config-cache-"*
}

invoke_claude() {
  local prompt="$1"
  local output
  output=$(cd "$WORK_DIR" && "$CLAUDE_BIN" -p "$prompt" \
    --plugin-dir "$SB_ROOT" \
    --output-format text \
    --max-budget-usd "$MAX_BUDGET" \
    --verbose 2>&1) || true
  printf '%s' "$output"
}

assert_response_contains() {
  local label="$1"
  local response="$2"
  local needle="$3"
  if printf '%s' "$response" | grep -iE "$needle" >/dev/null 2>&1; then
    PASS=$((PASS + 1))
    printf 'PASS: %s\n' "$label"
  else
    FAIL=$((FAIL + 1))
    printf 'FAIL: %s\n  (expected pattern "%s" in response)\n' "$label" "$needle"
    printf '  Response snippet: %s\n' "$(printf '%s' "$response" | head -c 400)"
  fi
}

assert_response_not_contains() {
  local label="$1"
  local response="$2"
  local needle="$3"
  if ! printf '%s' "$response" | grep -iE "$needle" >/dev/null 2>&1; then
    PASS=$((PASS + 1))
    printf 'PASS: %s\n' "$label"
  else
    FAIL=$((FAIL + 1))
    printf 'FAIL: %s\n  (unexpected pattern "%s" found in response)\n' "$label" "$needle"
    printf '  Response snippet: %s\n' "$(printf '%s' "$response" | head -c 400)"
  fi
}

assert_state_contains() {
  local label="$1"
  local skill_name="$2"
  if [[ -f "$TMPSTATE" ]] && grep -qx "$skill_name" "$TMPSTATE" 2>/dev/null; then
    PASS=$((PASS + 1))
    printf 'PASS: %s\n' "$label"
  else
    FAIL=$((FAIL + 1))
    printf 'FAIL: %s\n  (skill "%s" not found in state file %s)\n' "$label" "$skill_name" "$TMPSTATE"
    if [[ -f "$TMPSTATE" ]]; then
      printf '  State contents: %s\n' "$(cat "$TMPSTATE")"
    else
      printf '  State file does not exist.\n'
    fi
  fi
}

assert_state_not_contains() {
  local label="$1"
  local skill_name="$2"
  if [[ ! -f "$TMPSTATE" ]] || ! grep -qx "$skill_name" "$TMPSTATE" 2>/dev/null; then
    PASS=$((PASS + 1))
    printf 'PASS: %s\n' "$label"
  else
    FAIL=$((FAIL + 1))
    printf 'FAIL: %s\n  (unexpected skill "%s" found in state file)\n' "$label" "$skill_name"
  fi
}

assert_file_exists() {
  local label="$1"
  local filepath="$2"
  if [[ -e "$filepath" ]]; then
    PASS=$((PASS + 1))
    printf 'PASS: %s\n' "$label"
  else
    FAIL=$((FAIL + 1))
    printf 'FAIL: %s\n  (file/dir not found: %s)\n' "$label" "$filepath"
  fi
}

print_results() {
  printf '\nResults: %d passed, %d failed\n' "$PASS" "$FAIL"
  [[ $FAIL -eq 0 ]] && exit 0 || exit 1
}

seed_state() {
  # Write given skill names (one per line) to $TMPSTATE
  mkdir -p "$(dirname "$TMPSTATE")"
  : > "$TMPSTATE"
  for skill in "$@"; do
    printf '%s\n' "$skill" >> "$TMPSTATE"
  done
}
