# Silver Bullet Live AI E2E Tests

These tests invoke the **real `claude` CLI** with the Silver Bullet plugin loaded and stored credentials. They verify that SB enforcement hooks (dev-cycle-check, record-skill, stop-check, compliance-status, forbidden-skill-check) actually work when Claude AI triggers them via real tool usage.

## Prerequisites

- `claude` CLI installed at `/Users/shafqat/.local/bin/claude`
- Authenticated with valid Anthropic credentials (`claude auth` or `ANTHROPIC_API_KEY` set)
- `jq` installed (`brew install jq`)
- Git available

## Cost Warning

**Each invocation costs approximately $0.01-0.05.**

- Full suite (8 scenarios): estimated **$0.08-$0.40** per run
- Cheapest subset (skill recording only, 2 invocations): ~$0.02-$0.10

## Running the Tests

Run the full suite:
```bash
bash tests/live/run-live-tests.sh
```

Run a single cheaper subset first to validate setup:
```bash
bash tests/live/test-live-skill-recording.sh
```

Run individual scenario files:
```bash
bash tests/live/test-live-enforcement.sh
bash tests/live/test-live-skill-recording.sh
bash tests/live/test-live-full-scenario.sh
```

## Test Scenarios

| File | Scenarios | What it tests |
|------|-----------|---------------|
| test-live-enforcement.sh | S1-S4 | HARD STOP blocking, planning gate, forbidden skills, stop-check |
| test-live-skill-recording.sh | S5-S6 | Skill recording to state file, compliance-status output |
| test-live-full-scenario.sh | S7-S8 | Session initialization, abbreviated SDLC lifecycle |

## Isolation

Each test uses:
- An isolated temp workspace directory (`mktemp -d`)
- Isolated state files: `~/.claude/.silver-bullet/live-test-state-{PID}`
- Isolated trivial files: `~/.claude/.silver-bullet/live-test-trivial-{PID}`

All temp files are cleaned up after each scenario.

## Not Included in Unit/Integration Suites

These tests are **NOT** included in `run-all-tests.sh`. Run them separately via `run-live-tests.sh` when you need to validate real AI + hook integration.
