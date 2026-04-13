#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

echo "=== Live Skill Recording Tests ==="

# --- S5: quality-gates skill invoked and recorded ---
echo "--- S5: quality-gates skill recorded ---"
live_setup
response=$(invoke_claude "Invoke the quality-gates skill for this project. Use the Skill tool to call quality-gates.")
sleep 2
assert_state_contains "S5: quality-gates recorded in state" "quality-gates"
assert_response_contains "S5: response mentions quality-gates or skill recorded" "$response" "quality-gates|Skill recorded|recorded"
live_teardown

# --- S6: compliance-status shows progress ---
echo "--- S6: compliance-status shows progress ---"
live_setup
seed_state "quality-gates"
response=$(invoke_claude "Show me the Silver Bullet compliance status for this project. Just show the status, don't invoke any skills.")
sleep 2
# compliance-status.sh outputs "PLANNING 1/1" when quality-gates is recorded
assert_response_contains "S6: response mentions PLANNING" "$response" "PLANNING"
assert_response_contains "S6: response mentions fraction" "$response" "1/1|0/|[0-9]/[0-9]"
live_teardown

print_results
