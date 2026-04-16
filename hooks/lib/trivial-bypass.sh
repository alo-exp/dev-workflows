# shellcheck shell=bash
# Silver Bullet — trivial-session bypass guard (single source of truth)
# Sourced by: stop-check.sh, ci-status-check.sh
# If the trivial file exists (real file, not symlink), the session is trivial — caller should exit 0.
sb_trivial_bypass() {
  local trivial_path="${1:-${HOME}/.claude/.silver-bullet/trivial}"
  if [[ -f "$trivial_path" && ! -L "$trivial_path" ]]; then
    exit 0
  fi
}
