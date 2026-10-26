# mogenius claude-first sandbox: seed Claude Code config and drop into `claude`
# on any interactive login (SSH gateway, exec). Sourced from both login shells
# (via /etc/profile.d) and non-login interactive shells (via ~/.bashrc). Guarded
# so it runs once and only for real TTYs — non-interactive `claude -p …` runs and
# other tooling are unaffected.
if [ -z "${CLAUDE_STARTED:-}" ] && [ -t 1 ] && command -v claude >/dev/null 2>&1; then
  export CLAUDE_STARTED=1
  /usr/local/bin/seed-claude-config.sh 2>/dev/null || true
  exec claude
fi
