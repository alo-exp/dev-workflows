# CI/CD

## Pipeline: GitHub Actions

**File:** `.github/workflows/ci.yml`
**Trigger:** Every push and pull request to any branch.

### Pipeline Steps

| Step | What it checks | Fail condition |
|------|----------------|----------------|
| Validate JSON files | `plugin.json`, `marketplace.json`, `hooks.json`, `templates/silver-bullet.config.json.default`, `package.json` pass `jq empty` | Malformed JSON |
| Check hook executability | All `hooks/*.sh` and `scripts/*.sh` are `chmod +x` | Non-executable hook |
| Verify hooks.json references | Every `command` value in `hooks.json` points to an existing file | Missing hook script |
| Check template placeholders | `CLAUDE.md.base`, `silver-bullet.md.base`, `silver-bullet.config.json.default` contain required `{{…}}` tokens | Placeholder stripped during edit |
| Lint shell scripts | `shellcheck --exclude=SC2317 hooks/*.sh scripts/*.sh` | ShellCheck errors |

### Known CI gaps (tracked in `docs/tech-debt.md`)

These checks are **not yet in CI** — they are enforced manually during code review today:
- `required_deploy` / `all_tracked` correctness assertions (jq)
- `docs/workflows/` ↔ `templates/workflows/` byte-parity (diff)

## Release Process

Releases use `gh release create` after the `§9 pre-release quality gate` stages 1–4 pass.
The `/create-release` skill orchestrates:
1. Pre-release quality gate (4-stage internal gate: JSON validate, hook test, template parity, changelog entry)
2. `package.json` version bump
3. Git tag (`vX.Y.Z`)
4. `gh release create` with structured notes (features, fixes, breaking changes)

### Breaking change policy

A semver minor bump (`v0.X.0`) is used when new skills are added to `required_deploy`,
because existing users will see `completion-audit.sh` block their commits until they
invoke the newly required skills. This is an intentional tightening — documented prominently
in release notes.

## Local Validation

Before pushing, run CI checks locally:

```bash
# Validate JSON
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json hooks/hooks.json \
          templates/silver-bullet.config.json.default package.json; do
  jq empty "$f" && echo "Valid: $f"
done

# Lint shell
shellcheck --exclude=SC2317 hooks/*.sh scripts/*.sh

# Template parity
diff docs/workflows/full-dev-cycle.md templates/workflows/full-dev-cycle.md
diff docs/workflows/devops-cycle.md templates/workflows/devops-cycle.md
```
