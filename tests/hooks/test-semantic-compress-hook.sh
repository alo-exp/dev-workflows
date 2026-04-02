#!/usr/bin/env bash
set -euo pipefail
PASS=0; FAIL=0

assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [[ "$actual" == "$expected" ]]; then echo "PASS: $desc"; (( PASS++ )) || true
  else echo "FAIL: $desc"; echo "  expected: [$expected]"; echo "  actual:   [$actual]"; (( FAIL++ )) || true; fi
}

HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/hooks/semantic-compress.sh"

# Test 1: non-GSD skill → no output, exit 0
result=$(printf '{"tool_input":{"skill":"superpowers:brainstorming"}}' | "$HOOK" 2>/dev/null || true)
assert_eq "non-GSD skill: no output" "" "$result"

# Test 2: gsd:execute-phase → hook delegates (no .planning/ = no output)
result=$(printf '{"tool_input":{"skill":"gsd:execute-phase"}}' | "$HOOK" 2>/dev/null || true)
assert_eq "gsd:execute-phase without planning: no output" "" "$result"

# Test 3: gsd:plan-phase → same
result=$(printf '{"tool_input":{"skill":"gsd:plan-phase"}}' | "$HOOK" 2>/dev/null || true)
assert_eq "gsd:plan-phase without planning: no output" "" "$result"

# Test 4: gsd:discuss-phase → same
result=$(printf '{"tool_input":{"skill":"gsd:discuss-phase"}}' | "$HOOK" 2>/dev/null || true)
assert_eq "gsd:discuss-phase without planning: no output" "" "$result"

# Test 5: gsd:research-phase → same
result=$(printf '{"tool_input":{"skill":"gsd:research-phase"}}' | "$HOOK" 2>/dev/null || true)
assert_eq "gsd:research-phase without planning: no output" "" "$result"

# Test 6: missing skill field → no output, no crash
result=$(printf '{"tool_input":{}}' | "$HOOK" 2>/dev/null || true)
assert_eq "missing skill field: no output" "" "$result"

# Test 7: empty stdin → no output, no crash
result=$(printf '' | "$HOOK" 2>/dev/null || true)
assert_eq "empty stdin: no output" "" "$result"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[[ $FAIL -eq 0 ]]
