#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

echo "=== Live Full Scenario Tests ==="

# --- S7: Session state initialized ---
echo "--- S7: Session initialization ---"
live_setup
response=$(invoke_claude "Initialize a Silver Bullet session for this project. This is a new session.")
sleep 2
# session-start hook fires and creates state directory
assert_file_exists "S7: SB state directory exists" "${HOME}/.claude/.silver-bullet"
assert_response_contains "S7: response acknowledges session or Silver Bullet" "$response" "Silver Bullet|session|initialized|workflow"
live_teardown

# --- S8: Abbreviated lifecycle (quality-gates -> code-review -> edit) ---
echo "--- S8: Abbreviated lifecycle ---"
live_setup

# Step 1: invoke quality-gates
echo "  S8.1: Invoking quality-gates..."
response1=$(invoke_claude "Invoke the quality-gates skill for this project.")
sleep 2
assert_state_contains "S8.1: quality-gates recorded" "quality-gates"

# Step 2: seed code-review and related review skills (saves cost vs real invocation)
echo "  S8.2: Seeding code-review state..."
seed_state "quality-gates" "code-review" "requesting-code-review" "receiving-code-review"
assert_state_contains "S8.2: code-review in state" "code-review"

# Step 3: attempt edit (should succeed at Stage C)
echo "  S8.3: Attempting edit at Stage C..."
response3=$(invoke_claude "Edit the file src/routes/todos.js and add a comment at the very top: '// S8 lifecycle test'. Just add this one comment line.")
sleep 2
assert_response_not_contains "S8.3: no HARD STOP" "$response3" "HARD STOP"
assert_response_not_contains "S8.3: no Planning incomplete" "$response3" "Planning incomplete"

live_teardown

print_results
