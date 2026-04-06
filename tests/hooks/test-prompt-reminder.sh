#!/usr/bin/env bash
# Tests for hooks/prompt-reminder.sh
# Verifies UserPromptSubmit hook output format and bypass conditions.

set -euo pipefail

HOOK="$(cd "$(dirname "$0")/../.." && pwd)/hooks/prompt-reminder.sh"
PASS=0
FAIL=0

# ── Test infrastructure ───────────────────────────────────────────────────────
# State files MUST be within ~/.claude/ due to security path validation in hooks.
SB_TEST_DIR="${HOME}/.claude/.silver-bullet"
mkdir -p "$SB_TEST_DIR"
TEST_RUN_ID="$$"

cleanup_all() { rm -f "${SB_TEST_DIR}/test-state-${TEST_RUN_ID}" "${SB_TEST_DIR}/trivial-test-${TEST_RUN_ID}"; }
trap cleanup_all EXIT

write_cfg() {
  cat > "$TMPCFG" << EOF
{
  "project": { "src_pattern": "/src/", "active_workflow": "full-dev-cycle" },
  "skills": {
    "required_planning": ["quality-gates"],
    "required_deploy": ["quality-gates","code-review","testing-strategy","documentation","finishing-a-development-branch"],
    "all_tracked": ["quality-gates","code-review"]
  },
  "state": { "state_file": "${TMPSTATE}", "trivial_file": "${SB_TEST_DIR}/trivial-test-${TEST_RUN_ID}" }
}
EOF
}

setup() {
  TMPDIR_TEST=$(mktemp -d)
  TMPSTATE="${SB_TEST_DIR}/test-state-${TEST_RUN_ID}"
  TMPCFG="${TMPDIR_TEST}/.silver-bullet.json"
  rm -f "$TMPSTATE"
  export SILVER_BULLET_STATE_FILE="$TMPSTATE"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
  rm -f "$TMPSTATE"
}

run_hook() {
  # prompt-reminder does NOT read stdin — just run script with PWD set to project dir
  ( cd "$TMPDIR_TEST" && bash "$HOOK" 2>/dev/null )
}

assert_contains() {
  local label="$1"
  local output="$2"
  local needle="$3"
  if printf '%s' "$output" | grep -q "$needle"; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label — expected '$needle' in: $output"
    FAIL=$((FAIL + 1))
  fi
}

assert_not_contains() {
  local label="$1"
  local output="$2"
  local needle="$3"
  if ! printf '%s' "$output" | grep -q "$needle"; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label — expected '$needle' NOT in: $output"
    FAIL=$((FAIL + 1))
  fi
}

assert_empty() {
  local label="$1"
  local output="$2"
  if [[ -z "$output" ]]; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label — expected empty output, got: $output"
    FAIL=$((FAIL + 1))
  fi
}

# ── Tests ─────────────────────────────────────────────────────────────────────
echo "=== prompt-reminder.sh tests ==="

# Test 1: No config file -> exit 0, no output
echo "--- Test 1: No config file ---"
setup
# No .silver-bullet.json in dir -> silent exit
out=$(run_hook)
assert_empty "no config file -> silent exit, no output" "$out"
teardown

# Test 2: All skills complete -> output contains "all required skills complete"
echo "--- Test 2: All skills complete ---"
setup
write_cfg
cat > "$TMPSTATE" << 'EOF'
quality-gates
code-review
testing-strategy
documentation
finishing-a-development-branch
EOF
out=$(run_hook)
assert_contains "all skills complete -> contains all-complete message" "$out" "all required skills complete"
teardown

# Test 3: Missing skills -> output contains "Missing:" and the skill names
echo "--- Test 3: Missing skills -> Missing label and skill name ---"
setup
write_cfg
echo "quality-gates" > "$TMPSTATE"
out=$(run_hook)
assert_contains "missing skills -> output contains 'Missing:'" "$out" "Missing:"
assert_contains "missing skills -> output contains 'code-review'" "$out" "code-review"
teardown

# Test 4: Missing skills -> output contains count "(N of M complete)"
echo "--- Test 4: Missing skills -> count format (N of M complete) ---"
setup
write_cfg
echo "quality-gates" > "$TMPSTATE"
out=$(run_hook)
assert_contains "missing skills -> output contains 'of' count" "$out" "of"
assert_contains "missing skills -> output contains 'complete'" "$out" "complete"
teardown

# Test 5: Trivial file present -> exit 0, no output
echo "--- Test 5: Trivial bypass ---"
setup
write_cfg
# No skills recorded — would normally output missing list
rm -f "$TMPSTATE"
# Create trivial file (not a symlink)
touch "${SB_TEST_DIR}/trivial-test-${TEST_RUN_ID}"
out=$(run_hook)
assert_empty "trivial file present -> silent exit, no output" "$out"
teardown

# ── Results ───────────────────────────────────────────────────────────────────
echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
