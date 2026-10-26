#!/usr/bin/env bash
# Pre-answer Claude Code's first-run prompts from the runtime-injected
# credentials so `claude` starts straight into a session — no theme/login wizard
# and no "Do you want to use this API key?".
#
# The credential is injected as env at pod start (Secret `sandbox-provider-keys`),
# never baked into the image. Claude stores an approved API key as its last 20
# characters under customApiKeyResponses.approved (the cli computes it as
# `key.slice(-20)`); writing that entry is what suppresses the prompt. With
# CLAUDE_CODE_OAUTH_TOKEN instead of ANTHROPIC_API_KEY no approval is needed, and
# this then only marks onboarding complete.
set -euo pipefail

CFG="${HOME:-/home/coder}/.claude.json"

base='{}'
if [ -f "$CFG" ]; then base="$(cat "$CFG")"; fi

approved='[]'
if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  # tail -c 20 == JS slice(-20): last 20 chars, or the whole key if shorter.
  suffix="$(printf '%s' "$ANTHROPIC_API_KEY" | tail -c 20)"
  approved="$(jq -cn --arg s "$suffix" '[$s]')"
fi

tmp="$(mktemp "${CFG}.XXXXXX")"
jq -n \
  --argjson base "$base" \
  --argjson approved "$approved" \
  '$base
   + {hasCompletedOnboarding: true, theme: "dark"}
   + {customApiKeyResponses: {approved: $approved, rejected: (($base.customApiKeyResponses.rejected) // [])}}' \
  > "$tmp"
mv "$tmp" "$CFG"
