# Image of the `platform-test` sandbox profile: the default sandbox image plus
# a browser for agents that test the mogenius platform through its UI.
#
# Built on the published sandbox-default image, so code-server, Claude Code,
# Node.js, Python and the onboarding fix stay identical; raise BASE_VERSION
# with the chart's releases like the other pins. Adds Playwright MCP
# (`playwright-mcp`, https://github.com/microsoft/playwright-mcp) and the
# Chromium build that exactly this Playwright MCP needs, installed with the
# Playwright it depends on, so the two cannot drift apart. The browser lives
# in /opt/ms-playwright and is never downloaded at run time.
#
# The MCP configuration is not part of the image: claude-code runs with
# --strict-mcp-config and gets its servers per run from the test suite.
# Chromium runs as uid 1000 without privileges and without its own sandbox
# (which needs user namespaces most clusters' seccomp profile forbids):
# Playwright MCP launches the bundled Chromium with chromiumSandbox off, and
# callers pass `--no-sandbox` as well so a changed default cannot break it.
ARG BASE_VERSION=1.2.1
FROM ghcr.io/mogenius/agent-sandbox-chart/sandbox-default:${BASE_VERSION}

USER root
ARG PLAYWRIGHT_MCP_VERSION=0.0.83
# Playwright MCP defaults to the Chrome channel, which is not installed:
# point it at the bundled Chromium so `playwright-mcp` works without flags.
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/ms-playwright \
    PLAYWRIGHT_MCP_BROWSER=chromium
RUN npm install -g "@playwright/mcp@${PLAYWRIGHT_MCP_VERSION}" \
 && cd "$(npm root -g)/@playwright/mcp" \
 && npx --no-install playwright install --with-deps chromium \
 && chmod -R a+rX /opt/ms-playwright \
 && npm cache clean --force \
 && rm -rf /var/lib/apt/lists/*

USER coder
