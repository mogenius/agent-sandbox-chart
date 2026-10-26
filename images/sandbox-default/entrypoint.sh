#!/usr/bin/env bash
# Keep-alive entrypoint for the claude-first sandbox. There is no HTTP server:
# the pod stays ready (warm pool) while interactive logins launch Claude Code per
# session via the login shell (see /etc/profile.d/zz-claude-login.sh). Seed the
# config once up front too, so even a non-interactive `claude -p …` run
# authenticates without a prompt.
set -euo pipefail

/usr/local/bin/seed-claude-config.sh 2>/dev/null || true

exec sleep infinity
