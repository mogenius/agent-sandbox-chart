# Default sandbox image of the mogenius Agent Sandbox blueprint — claude-first.
#
# No web IDE: the sandbox is reached through the mogenius SSH gateway (or the
# SDK's exec API), and an interactive login drops straight into Claude Code.
# Tooling an agent expects: Node.js LTS with TypeScript/tsx, Python 3 with
# pip/venv and uv, git, ripgrep, jq and build tools. Runs as the unprivileged
# user `coder` (uid 1000); the sandbox volume is mounted at /home/coder/project.
#
# No HTTP server and no exposed port — the `default` template sets `port: 0` and
# `probes.enabled: false`. The entrypoint is a keep-alive so warm-pool pods stay
# ready; `claude` runs per login shell, not as PID 1, so a session that exits
# never takes the pod down.
#
# Authentication: `claude` reads CLAUDE_CODE_OAUTH_TOKEN or ANTHROPIC_API_KEY
# from the chart's env (Secret `sandbox-provider-keys`). The credential is NOT
# baked into the image — it is injected at pod start. The entrypoint and the
# login shell seed ~/.claude.json so the first-run wizard and the "use this API
# key?" prompt are both pre-answered (see seed-claude-config.sh).
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash ca-certificates curl git jq less openssh-server ripgrep rsync tar unzip \
      python3 python3-pip python3-venv python3-dev build-essential pkg-config \
 && rm -rf /var/lib/apt/lists/* \
 && ln -sf /usr/bin/python3 /usr/local/bin/python \
 && useradd --create-home --uid 1000 --shell /bin/bash coder \
 && mkdir -p /home/coder/project /home/coder/.local/bin \
 && chown -R coder:coder /home/coder

# uv: fast Python package manager, what most agent frameworks call today.
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh

# Node.js LTS: Claude Code and the TypeScript runners agents call (NodeSource
# has amd64 and arm64 builds).
ARG NODE_MAJOR=22
RUN curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && rm -rf /var/lib/apt/lists/*

# Claude Code plus the TypeScript runners, globally so they are on PATH for
# every user.
ARG CLAUDE_CODE_VERSION=latest
RUN npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}" typescript tsx \
 && npm cache clean --force

# Runtime config seeder, keep-alive entrypoint, and the login snippet that drops
# interactive sessions into Claude Code.
COPY --chmod=0755 seed-claude-config.sh /usr/local/bin/seed-claude-config.sh
COPY --chmod=0755 entrypoint.sh /usr/local/bin/sandbox-entrypoint.sh
COPY --chmod=0644 claude-login.sh /etc/profile.d/zz-claude-login.sh

USER coder
WORKDIR /home/coder/project
ENV HOME=/home/coder \
    PATH="/home/coder/.local/bin:${PATH}" \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    UV_LINK_MODE=copy

# Login shells (SSH) read /etc/profile.d; non-login interactive shells (e.g.
# `exec … bash`) read ~/.bashrc — source the same snippet from both.
RUN printf '\n[ -r /etc/profile.d/zz-claude-login.sh ] && . /etc/profile.d/zz-claude-login.sh\n' \
      >> /home/coder/.bashrc

ENTRYPOINT ["/usr/local/bin/sandbox-entrypoint.sh"]
