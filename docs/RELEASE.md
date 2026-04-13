# Release Process

## Versioning Policy

- **Patch** (`v0.X.Y`): Bug fixes, doc updates, no enforcement changes
- **Minor** (`v0.X.0`): New features, new enforcement rules, new skills added to `required_deploy` (breaking — blocks existing users' commits until they invoke new required skills)
- **Major** (`vX.0.0`): Reserved for architectural changes

## Release Steps

### 1. Pre-Release Quality Gate (Mandatory)

Four stages must pass in the current session. See `docs/ENFORCEMENT.md` for details.

| Stage | Gate |
|-------|------|
| 1 | Code Review Triad — loop until zero issues |
| 2 | Big-Picture Consistency Audit — two clean passes |
| 3 | Public-Facing Content Refresh — all surfaces current |
| 4 | Security Audit (SENTINEL) — two clean passes |

Each stage requires `/superpowers:verification-before-completion` invocation. Markers cleared on session start.

### 2. Version Bump

Update `package.json` version field.

### 3. Changelog

Update `docs/CHANGELOG.md` with features, fixes, and breaking changes.

### 4. Tag and Release

```bash
git tag vX.Y.Z
gh release create vX.Y.Z --title "vX.Y.Z" --notes "..."
```

`completion-audit.sh` blocks `gh release create` until all `required_deploy` skills AND all 4 quality gate stage markers are in the state file.

### 5. Post-Release

- Verify CI green on the release tag
- Confirm plugin cache update works via `/silver:update`
- Update site if needed (Stage 3 should have covered this)

## Plugin Update Mechanism

Users update via `/silver:update` which:
1. Reads installed version from `~/.claude/plugins/installed_plugins.json`
2. Resolves GitHub repo from `package.json` in the cache
3. Fetches latest release, compares versions
4. Clones new release into plugin cache
5. Updates registry entry (old cache preserved for rollback)

See `docs/internal/update-command-instructions.md` for full implementation guide.

## CI Pipeline

**File:** `.github/workflows/ci.yml` — runs on every push and PR.

| Step | Validates |
|------|-----------|
| JSON validation | plugin.json, marketplace.json, hooks.json, config template, package.json |
| Hook executability | All hooks/*.sh and scripts/*.sh are chmod +x |
| hooks.json references | Every command in hooks.json points to existing file |
| Template placeholders | Required `{{...}}` tokens present in base files |
| Shell lint | ShellCheck on all hooks and scripts |

## Scalability

**Fixed** — process doc rewritten when release process changes. Not append-only.
