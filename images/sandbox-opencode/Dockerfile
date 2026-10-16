# Image of the `opencode` sandbox profile: the opencode 2.x server plus the
# tooling a coding agent needs to work on real repositories.
#
# The upstream image (ghcr.io/anomalyco/opencode) is Alpine with the opencode
# binary and ripgrep only: no git, no language toolchains. An agent in it can
# neither clone a repository nor build or test it. opencode 2.x ships as a
# musl binary only in that image, so this one stays on Alpine and adds git,
# Node.js, Python, Go and build tools.
#
# Claude Code is installed too, at the version of sandbox-default: tools such as
# mo-platform-tests' report agent run `claude -p` in any sandbox, whatever
# agent the profile is for. On musl it uses the system ripgrep.
#
# Runs as uid 1000 with HOME=/workspace (the profile's volume), like the
# profile's securityContext expects. Serves the opencode HTTP API on 8888;
# the chart's probes use /api/info.
ARG OPENCODE_VERSION=2.0.32
FROM ghcr.io/anomalyco/opencode:${OPENCODE_VERSION} AS opencode

FROM alpine:3.24

ARG CLAUDE_CODE_VERSION=latest

RUN apk add --no-cache \
      bash ca-certificates curl git jq less openssh-client ripgrep tar unzip \
      build-base make \
      nodejs npm \
      python3 py3-pip \
      go \
      libgcc libstdc++ \
 && npm install -g pnpm@9 typescript tsx "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}" \
 && npm cache clean --force \
 && addgroup -g 1000 agent \
 && adduser -D -u 1000 -G agent -h /workspace agent

COPY --from=opencode /usr/local/bin/opencode /usr/local/bin/opencode

USER 1000:1000
WORKDIR /workspace
ENV HOME=/workspace \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    GOPATH=/workspace/.go \
    GOFLAGS=-modcacherw \
    USE_BUILTIN_RIPGREP=0 \
    PATH=/workspace/.go/bin:/workspace/.local/bin:/usr/local/bin:/usr/bin:/bin

EXPOSE 8888
ENTRYPOINT ["opencode"]
CMD ["serve", "--hostname", "0.0.0.0", "--port", "8888"]
