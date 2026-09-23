# agent-sandbox-chart

Helm chart and default sandbox image behind the mogenius **Agent Sandbox** blueprint
([mogenius/helm-chart-blueprints](https://github.com/mogenius/helm-chart-blueprints),
`charts/agent-sandbox.yaml`).

```
helm/mogenius-agent-sandbox/    the chart: kubernetes-sigs/agent-sandbox controller + CRDs,
                                sandbox namespace, profiles with warm pools
images/sandbox-default/         Dockerfile of the default sandbox image
                                (code-server, Python 3, uv, Node.js, Claude Code)
hack/                           update-upstream, upgrade-crds, publish-chartmuseum
.github/workflows/chart.yaml    lint, kind install test, publish to helm.mogenius.com/public
.github/workflows/image.yaml    build + push the image to ghcr.io (amd64, arm64)
```

Published artifacts:

* Chart `mogenius/mogenius-agent-sandbox` in `https://helm.mogenius.com/public`
* Image `ghcr.io/mogenius/agent-sandbox-chart/sandbox-default`, pinned by digest in the chart

## The chart

| Part | What it installs |
| --- | --- |
| `controller.*` | kubernetes-sigs/agent-sandbox controller **with extensions**, RBAC, metrics Service — into the release namespace (`agent-sandbox-system`) |
| `crds/` | the four v1beta1 CRDs of the pinned upstream release (`appVersion`) |
| `sandboxes.namespace` | the namespace sandbox pods run in |
| `sandboxes.serviceAccount` | `sandbox-runtime`: no RBAC, no token |
| `sandboxes.profiles.<name>` | a `SandboxTemplate` and a `SandboxWarmPool` per enabled profile |

Profiles are the knobs the Sandboxes page in mogenius edits: image, resources, storage,
RuntimeClass (`gvisor` where available) and the warm pool size. `default` is what the
mogenius Sandbox SDK claims from; `opencode` is a ready-made second profile, disabled by
default. Provider credentials come from the Secret `sandbox-provider-keys` in the sandbox
namespace (`anthropic-api-key`, `claude-code-oauth-token`), injected as optional env into
every profile; the Sandboxes page manages it.

Network policy follows upstream's managed default (internet egress only, RFC1918 and
link-local denied). `networkPolicy.additionalBlockedCidrs` adds service CIDRs outside
RFC1918 (GKE: `34.118.224.0/20`).

### Try it

```sh
helm repo add mogenius https://helm.mogenius.com/public
helm install agent-sandbox mogenius/mogenius-agent-sandbox -n agent-sandbox-system --create-namespace --wait
kubectl -n agent-sandbox get sandboxwarmpool,sandboxes,pods
```

Clusters that still carry agent-sandbox **< v0.5.0** must drop the old CRDs first; there is
no in-place upgrade (upstream removed `v1alpha1` and the conversion webhook in 1.0).

### Upgrading

Helm installs `crds/` once and never touches them again. When `appVersion` changes:

```sh
hack/upgrade-crds.sh
helm upgrade agent-sandbox mogenius/mogenius-agent-sandbox -n agent-sandbox-system --reuse-values
```

To move the chart to a new upstream release: `hack/update-upstream.sh v1.0.3`, diff
`templates/controller/`, bump `version` in `Chart.yaml`, commit.

## The default image

`images/sandbox-default`: `codercom/code-server` plus Python 3 with pip/venv and uv, Node.js
LTS with `typescript` and `tsx`, git, build tools and Claude Code. Runs as `coder` (uid 1000),
serves VS Code on 8080 without its own auth (the mogenius tunnel authenticates), workspace
volume at `/home/coder/project`, Claude Code's first-run wizard pre-completed so `claude`
authenticates from `CLAUDE_CODE_OAUTH_TOKEN` or `ANTHROPIC_API_KEY`.

### Bring your own sandbox image

Copy the Dockerfile, add your tooling, build for `linux/amd64` and `linux/arm64`, push to a
registry your cluster can pull from, and set it as the `default` profile's image in the
Sandboxes page. Keep the contract the chart relies on: uid 1000, the workspace at
`/home/coder/project`, `GET /healthz` on port 8080, and `bash`, `curl`, `tar` for the SSH
gateway and VS Code Remote-SSH.

## Releasing

* Bump `images/sandbox-default/VERSION` and/or `helm/mogenius-agent-sandbox/Chart.yaml`.
* Push to `main`: `image.yaml` builds and pushes the image, `chart.yaml` lints, installs into
  kind (waiting for the image) and publishes the chart version to helm.mogenius.com if it is
  not there yet (secrets `MO_HELMUSER` / `MO_HELMPASS`).
* Pin the new image digest in `values.yaml` and bump the chart, then bump `version` in
  `mogenius/helm-chart-blueprints/charts/agent-sandbox.yaml` (Renovate proposes it).
