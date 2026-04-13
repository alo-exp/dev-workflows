#!/usr/bin/env bash
# Tests for hooks/ensure-model-routing.sh
# Verifies canary logic, path security, sed replacement, python insertion, and model routing.

set -euo pipefail

HOOK="$(cd "$(dirname "$0")/../.." && pwd)/hooks/ensure-model-routing.sh"
PASS=0
FAIL=0

# ── Helpers ───────────────────────────────────────────────────────────────────

assert_pass() {
  local label="$1"
  echo "  PASS: $label"
  PASS=$((PASS + 1))
}

assert_fail() {
  local label="$1"
  local reason="$2"
  echo "  FAIL: $label — $reason"
  FAIL=$((FAIL + 1))
}

assert_file_contains() {
  local label="$1"
  local path="$2"
  local needle="$3"
  if grep -q "$needle" "$path" 2>/dev/null; then
    assert_pass "$label"
  else
    assert_fail "$label" "expected '$needle' in $path"
  fi
}

assert_file_not_contains() {
  local label="$1"
  local path="$2"
  local needle="$3"
  if ! grep -q "$needle" "$path" 2>/dev/null; then
    assert_pass "$label"
  else
    assert_fail "$label" "expected '$needle' NOT in $path"
  fi
}

assert_exit_zero() {
  local label="$1"
  local exit_code="$2"
  if [[ "$exit_code" -eq 0 ]]; then
    assert_pass "$label"
  else
    assert_fail "$label" "exit code was $exit_code, expected 0"
  fi
}

assert_count_of() {
  local label="$1"
  local path="$2"
  local pattern="$3"
  local expected="$4"
  local actual
  actual=$(grep -c "$pattern" "$path" 2>/dev/null || true)
  if [[ "$actual" -eq "$expected" ]]; then
    assert_pass "$label"
  else
    assert_fail "$label" "expected $expected occurrences of '$pattern', got $actual"
  fi
}

# ── Setup helper ──────────────────────────────────────────────────────────────
# Creates a fake HOME with .claude/agents/ and .claude/.silver-bullet/
# Usage: make_fake_home
# Sets: FAKE_HOME, FAKE_AGENTS_DIR, FAKE_SB_DIR
make_fake_home() {
  FAKE_HOME="$(mktemp -d)"
  FAKE_AGENTS_DIR="${FAKE_HOME}/.claude/agents"
  FAKE_SB_DIR="${FAKE_HOME}/.claude/.silver-bullet"
  mkdir -p "$FAKE_AGENTS_DIR" "$FAKE_SB_DIR"
}

# Creates a gsd-*.md with YAML frontmatter and optional extra frontmatter lines
# Usage: make_agent_file <path> [extra_frontmatter_line]
make_agent_file() {
  local path="$1"
  local extra="${2:-}"
  {
    echo "---"
    echo "name: $(basename "$path" .md)"
    echo "description: Test agent"
    if [[ -n "$extra" ]]; then
      echo "$extra"
    fi
    echo "---"
    echo ""
    echo "Body content here."
  } > "$path"
}

run_hook() {
  local fake_home="$1"
  HOME="$fake_home" bash "$HOOK" 2>/dev/null
  echo $?
}

cleanup_fake_home() {
  [[ -n "${FAKE_HOME:-}" ]] && rm -rf "$FAKE_HOME" || true
}

trap cleanup_fake_home EXIT

# ── Tests ─────────────────────────────────────────────────────────────────────
echo "=== ensure-model-routing.sh tests ==="

# ── S1: Canary stale -> all directives applied ────────────────────────────────
echo "--- S1: Canary stale -> model directives applied ---"
make_fake_home

# gsd-planner.md WITHOUT model: opus (canary stale)
make_agent_file "${FAKE_AGENTS_DIR}/gsd-planner.md"
make_agent_file "${FAKE_AGENTS_DIR}/gsd-security-auditor.md"
make_agent_file "${FAKE_AGENTS_DIR}/gsd-executor.md"

exit_code=$(run_hook "$FAKE_HOME")
assert_exit_zero "S1: hook exits 0" "$exit_code"
assert_file_contains "S1: gsd-planner.md gets model: opus" \
  "${FAKE_AGENTS_DIR}/gsd-planner.md" "^model: opus"
assert_file_contains "S1: gsd-security-auditor.md gets model: opus" \
  "${FAKE_AGENTS_DIR}/gsd-security-auditor.md" "^model: opus"
assert_file_contains "S1: gsd-executor.md gets model: sonnet" \
  "${FAKE_AGENTS_DIR}/gsd-executor.md" "^model: sonnet"
# Log file should be written
assert_file_contains "S1: audit log written" \
  "${FAKE_SB_DIR}/model-routing-patch.log" "ensure-model-routing"

cleanup_fake_home

# ── S2: Canary fresh -> no-op ─────────────────────────────────────────────────
echo "--- S2: Canary fresh (gsd-planner has model: opus) -> no-op ---"
make_fake_home

make_agent_file "${FAKE_AGENTS_DIR}/gsd-planner.md" "model: opus"
make_agent_file "${FAKE_AGENTS_DIR}/gsd-executor.md"

# Capture checksum before
before_cksum=$(md5 -q "${FAKE_AGENTS_DIR}/gsd-planner.md" 2>/dev/null || md5sum "${FAKE_AGENTS_DIR}/gsd-planner.md" | awk '{print $1}')
before_executor_cksum=$(md5 -q "${FAKE_AGENTS_DIR}/gsd-executor.md" 2>/dev/null || md5sum "${FAKE_AGENTS_DIR}/gsd-executor.md" | awk '{print $1}')

exit_code=$(run_hook "$FAKE_HOME")
assert_exit_zero "S2: hook exits 0" "$exit_code"

after_cksum=$(md5 -q "${FAKE_AGENTS_DIR}/gsd-planner.md" 2>/dev/null || md5sum "${FAKE_AGENTS_DIR}/gsd-planner.md" | awk '{print $1}')
after_executor_cksum=$(md5 -q "${FAKE_AGENTS_DIR}/gsd-executor.md" 2>/dev/null || md5sum "${FAKE_AGENTS_DIR}/gsd-executor.md" | awk '{print $1}')

if [[ "$before_cksum" == "$after_cksum" ]]; then
  assert_pass "S2: gsd-planner.md not modified (no-op)"
else
  assert_fail "S2: gsd-planner.md not modified (no-op)" "checksum changed"
fi

if [[ "$before_executor_cksum" == "$after_executor_cksum" ]]; then
  assert_pass "S2: gsd-executor.md not modified (no-op)"
else
  assert_fail "S2: gsd-executor.md not modified (no-op)" "checksum changed"
fi

cleanup_fake_home

# ── S3: ~/.claude/agents/ directory missing -> silent exit 0 ─────────────────
echo "--- S3: agents dir missing -> silent exit 0 ---"
make_fake_home
# Remove agents dir entirely
rm -rf "${FAKE_AGENTS_DIR}"

exit_code=$(run_hook "$FAKE_HOME")
assert_exit_zero "S3: hook exits 0 when agents dir missing" "$exit_code"

cleanup_fake_home

# ── S4: Non-gsd-*.md files in agents dir are not processed ───────────────────
echo "--- S4: non-gsd-*.md files are not processed by the hook ---"
make_fake_home

# Canary stale
make_agent_file "${FAKE_AGENTS_DIR}/gsd-planner.md"
# A plain .md file that does not match gsd-*.md glob
cat > "${FAKE_AGENTS_DIR}/my-custom-agent.md" << 'EOF'
---
name: my-custom-agent
description: custom agent (not gsd-prefixed)
---
Body.
EOF
before_custom=$(cat "${FAKE_AGENTS_DIR}/my-custom-agent.md")

exit_code=$(run_hook "$FAKE_HOME")
assert_exit_zero "S4: hook exits 0 with non-gsd file present" "$exit_code"

after_custom=$(cat "${FAKE_AGENTS_DIR}/my-custom-agent.md")
if [[ "$before_custom" == "$after_custom" ]]; then
  assert_pass "S4: non-gsd-*.md file not touched by hook"
else
  assert_fail "S4: non-gsd-*.md file not touched by hook" "file was unexpectedly modified"
fi

# Verify the gsd file was still patched (hook ran normally)
assert_file_contains "S4: gsd-planner.md still patched correctly" \
  "${FAKE_AGENTS_DIR}/gsd-planner.md" "^model: opus"

cleanup_fake_home

# ── S5: gsd-executor.md has existing "model: sonnet" -> not duplicated ────────
echo "--- S5: existing model: line replaced not duplicated ---"
make_fake_home

# Canary stale
make_agent_file "${FAKE_AGENTS_DIR}/gsd-planner.md"
# Executor already has a model line (different value)
make_agent_file "${FAKE_AGENTS_DIR}/gsd-executor.md" "model: haiku"

exit_code=$(run_hook "$FAKE_HOME")
assert_exit_zero "S5: hook exits 0" "$exit_code"

assert_count_of "S5: exactly one model: line in gsd-executor.md" \
  "${FAKE_AGENTS_DIR}/gsd-executor.md" "^model:" 1
assert_file_contains "S5: model: sonnet (not haiku)" \
  "${FAKE_AGENTS_DIR}/gsd-executor.md" "^model: sonnet"
assert_file_not_contains "S5: no residual model: haiku" \
  "${FAKE_AGENTS_DIR}/gsd-executor.md" "model: haiku"

cleanup_fake_home

# ── S6: model_for_agent routing — planner/security-auditor=opus, others=sonnet ─
echo "--- S6: model_for_agent routing per agent name ---"
make_fake_home

make_agent_file "${FAKE_AGENTS_DIR}/gsd-planner.md"
make_agent_file "${FAKE_AGENTS_DIR}/gsd-security-auditor.md"
make_agent_file "${FAKE_AGENTS_DIR}/gsd-checker.md"
make_agent_file "${FAKE_AGENTS_DIR}/gsd-executor.md"

exit_code=$(run_hook "$FAKE_HOME")
assert_exit_zero "S6: hook exits 0" "$exit_code"

assert_file_contains "S6: gsd-planner -> opus" \
  "${FAKE_AGENTS_DIR}/gsd-planner.md" "^model: opus"
assert_file_contains "S6: gsd-security-auditor -> opus" \
  "${FAKE_AGENTS_DIR}/gsd-security-auditor.md" "^model: opus"
assert_file_contains "S6: gsd-checker -> sonnet" \
  "${FAKE_AGENTS_DIR}/gsd-checker.md" "^model: sonnet"
assert_file_contains "S6: gsd-executor -> sonnet" \
  "${FAKE_AGENTS_DIR}/gsd-executor.md" "^model: sonnet"

cleanup_fake_home

# ── Results ───────────────────────────────────────────────────────────────────
echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
