#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

echo "=== Live Enforcement Tests ==="

# --- S1: HARD STOP on edit-before-planning ---
echo "--- S1: HARD STOP on edit-before-planning ---"
live_setup
# State is empty — no skills recorded. Prompt Claude to edit a src file.
response=$(invoke_claude "Edit the file src/routes/todos.js and add a comment at the top that says '// S1 test comment'. Do not invoke any skills, just edit the file directly.")
sleep 2
# dev-cycle-check.sh should fire PreToolUse:Edit and return HARD STOP
assert_response_contains "S1: response mentions planning/HARD STOP/blocked" "$response" "planning|HARD STOP|BLOCKED|quality-gates|Planning incomplete"
assert_state_not_contains "S1: no edits recorded in state (edit was blocked)" "quality-gates"
live_teardown

# --- S2: Planning gate opens after quality-gates + code-review ---
echo "--- S2: Edit allowed after reaching Stage C ---"
live_setup
seed_state "quality-gates" "code-review" "requesting-code-review" "receiving-code-review"
response=$(invoke_claude "Edit the file src/routes/todos.js and add a comment at the top that says '// S2 test edit'. Just add the comment, nothing else.")
sleep 2
# With quality-gates AND code-review recorded, Stage C is reached — edit should succeed
assert_response_not_contains "S2: no HARD STOP in response" "$response" "HARD STOP"
assert_response_not_contains "S2: no BLOCKED planning incomplete" "$response" "BLOCKED.*Planning incomplete"
live_teardown

# --- S3: Forbidden skill blocked ---
echo "--- S3: Forbidden skill blocked ---"
live_setup
response=$(invoke_claude "Please invoke the executing-plans skill right now. Use the Skill tool to call executing-plans.")
sleep 2
# forbidden-skill-check.sh hardcoded list includes "executing-plans" — should deny
assert_response_contains "S3: response mentions forbidden/denied/not available/blocked" "$response" "FORBIDDEN SKILL|forbidden|denied|not available|cannot|blocked|BLOCKED"
live_teardown

# --- S4: Stop-check blocks completion with missing skills ---
echo "--- S4: Stop-check fires with missing skills ---"
live_setup
# Empty state — all required_deploy skills missing. Claude will try to complete and stop-check fires.
response=$(invoke_claude "Say hello and then stop. Do not invoke any skills or edit any files.")
sleep 2
# stop-check.sh fires on Stop event — should mention "Cannot complete" or missing skills
assert_response_contains "S4: response mentions missing skills or compliance" "$response" "Cannot complete|missing|required|compliance|Silver Bullet"
live_teardown

print_results
