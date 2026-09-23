#!/usr/bin/env bash
# Packages the chart and pushes it to the mogenius ChartMuseum
# (https://helm.mogenius.com/public), the repository the blueprint points to.
# The chart workflow does the same on pushes to main; this is the manual path.
#
#   CHARTMUSEUM_USER=... CHARTMUSEUM_PASSWORD=... hack/publish-chartmuseum.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
: "${CHARTMUSEUM_URL:=https://helm.mogenius.com}"
: "${CHARTMUSEUM_REPO:=public}"
: "${CHARTMUSEUM_USER:?set CHARTMUSEUM_USER}"
: "${CHARTMUSEUM_PASSWORD:?set CHARTMUSEUM_PASSWORD}"

OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT
helm lint "$ROOT/helm/mogenius-agent-sandbox"
helm package "$ROOT/helm/mogenius-agent-sandbox" -d "$OUT" >/dev/null
TGZ="$(ls "$OUT"/*.tgz)"
echo "pushing $(basename "$TGZ") to $CHARTMUSEUM_URL/$CHARTMUSEUM_REPO"
curl --fail-with-body -sS -u "$CHARTMUSEUM_USER:$CHARTMUSEUM_PASSWORD" \
  --data-binary "@$TGZ" "$CHARTMUSEUM_URL/api/$CHARTMUSEUM_REPO/charts"
echo
