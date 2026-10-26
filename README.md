# agent-sandbox-chart

Helm chart and sandbox images behind the mogenius **Agent Sandbox** blueprint
([mogenius/helm-chart-blueprints](https://github.com/mogenius/helm-chart-blueprints),
`charts/agent-sandbox.yaml`).

```
helm/mogenius-agent-sandbox/    the chart: kubernetes-sigs/agent-sandbox controller + CRDs,
                                sandbox namespace, profiles with warm pools
images/sandbox-default/         Dockerfile of the default sandbox image
                                (claude-first: Claude Code, Node.js, Python 3, uv — no web IDE)
images/sandbox-opencode/        Dockerfile of the opencode profile's image
                                (opencode 2.x server, git, Node.js, Python, Go)
images/sandbox-platform-test/   Dockerfile of the platform-test profile's image
                                (sandbox-default plus Playwright MCP and Chromium)
hack/                           update-upstream, upgrade-crds, publish-chartmuseum
.github/workflows/chart.yaml    lint and kind install test
.github/workflows/images.yaml   build the images and check their tools (pull requests)
.github/workflows/release.yaml  on a release tag: build the images (amd64, arm64),
                                set their tags in values.yaml, publish the chart
```

Published artifacts:

* Chart `mogenius/mogenius-agent-sandbox` in `https://helm.mogenius.com/public`
* Image `ghcr.io/mogenius/agent-sandbox-chart/sandbox-default`, tagged with the chart release
* Image `ghcr.io/mogenius/agent-sandbox-chart/sandbox-opencode`, tagged with the chart release
* Image `ghcr.io/mogenius/agent-sandbox-chart/sandbox-platform-test`, tagged with the chart release

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
default, that runs an opencode agent server and is what the mogenius Sandbox Agent Hub
creates its task sandboxes from; `platform-test`, also disabled by default, adds a headless
browser for agents that test the mogenius platform (mo-platform-tests). Provider credentials
come from the Secret `sandbox-provider-keys` in the sandbox namespace (`anthropic-api-key`,
`claude-code-oauth-token`), injected as optional env into every profile; the Sandboxes page
manages it.

A third, optional key `mogenius-api-key` in the same Secret is the mogenius API key of the
agent in a `platform-test` sandbox, injected as `MOGENIUS_API_KEY` into that profile only.
Use a personal access token of a dedicated test user with exactly the rights the tests need
(organization viewer, editor on the test cluster), never an admin key. The platform copies
the whole Secret into every namespace it creates a pool in, so the key travels with it. Env
is read at pod start: recycle the pool after changing a key. Until the Sandboxes page has a
field for it:

```sh
kubectl -n agent-sandbox patch secret sandbox-provider-keys --type merge \
  -p '{"stringData":{"mogenius-api-key":"<key>"}}'
```

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

`images/sandbox-default`: claude-first, no web IDE. Debian slim with Claude Code, Node.js LTS
(`typescript`, `tsx`), Python 3 with pip/venv and uv, git, ripgrep, jq and build tools. Runs
as `coder` (uid 1000), workspace volume at `/home/coder/project`. It serves no HTTP and
exposes no port — the `default` template sets `port: 0` and `probes.enabled: false`. The
entrypoint is a keep-alive (`sleep infinity`) so warm-pool pods stay ready; an interactive
login over the SSH gateway (or an `exec`) drops straight into `claude`, launched per session
rather than as PID 1. `claude` authenticates from `CLAUDE_CODE_OAUTH_TOKEN` or
`ANTHROPIC_API_KEY` injected at pod start; `seed-claude-config.sh` pre-answers the first-run
wizard and the API-key approval from that env, so no prompt appears (the key is never baked
into the image).

### Bring your own sandbox image

Copy the Dockerfile, add your tooling, build for `linux/amd64` and `linux/arm64`, push to a
registry your cluster can pull from, and set it as the `default` profile's image in the
Sandboxes page. Keep the contract the chart relies on: uid 1000, the workspace at
`/home/coder/project`, a long-running entrypoint (or set the template `command` to
`["sleep", "infinity"]`), and `bash`, `curl`, `tar` for the SSH gateway and VS Code
Remote-SSH. If your image serves HTTP, set the template's `port` and turn `probes` back on.

## The opencode image

`images/sandbox-opencode`: the opencode 2.x binary from `ghcr.io/anomalyco/opencode` on
Alpine, plus git, Node.js with `pnpm`, `typescript` and `tsx`, Python 3, Go and build tools.
The upstream image has none of these, so an agent in it could neither clone nor build or test a
repository. opencode 2.x ships as a musl binary only, which is why this image stays on Alpine
instead of extending the Debian-based default image. Runs as uid 1000 with
`HOME=/workspace` (the profile's volume) and serves the opencode API on 8888; the profile's
probes use `/api/info`. Renovate tracks the opencode version and keeps it on 2.x, the API the
Sandbox Agent Hub speaks.

## The platform-test image

`images/sandbox-platform-test`: the published `sandbox-default` image of the same release
(`BASE_VERSION`) plus [Playwright MCP](https://github.com/microsoft/playwright-mcp)
(`playwright-mcp`, pinned with `PLAYWRIGHT_MCP_VERSION`) and the Chromium build of exactly
the Playwright it depends on, in `/opt/ms-playwright`; nothing is downloaded at run time.
`PLAYWRIGHT_MCP_BROWSER=chromium` makes the bundled browser the default. About 1.5 GB larger
than the default image (Chromium, its headless shell and their system libraries), hence a
profile of its own.

There is no MCP configuration in the image: the agent gets its servers per run. A typical
entry is `playwright-mcp --headless --browser chromium --isolated --no-sandbox
--viewport-size 1440x900 --output-dir <dir>`; screenshots without a file name land in
`--output-dir`, ones with a file name relative to the working directory.

* **No Chromium sandbox.** Chromium's own sandbox needs user namespaces that the default
  seccomp profile of most clusters forbids. Playwright MCP already launches the bundled
  Chromium without it; `--no-sandbox` keeps it so. Isolation comes from the disposable pod,
  uid 1000 without privileges, and the chart's network policy.
* **`/dev/shm`.** Kubernetes gives containers 64 MB, on which Chromium crashes with larger
  pages; the profile mounts a 1 GiB memory-backed `emptyDir` there (`shmSizeLimit`), which
  counts against the 4 GiB memory limit.
* **Screenshots are not redacted.** Whatever the browser shows ends up in the picture; let
  the agent screenshot page content only, never pages that show keys or tokens.

## Releasing

* Conventional commits on `main`; Release Please opens the release pull request.
* Merging it tags the release: `release.yaml` builds the images with that tag, sets the tags
  in `values.yaml`, and publishes the chart to helm.mogenius.com (secrets `MO_HELMUSER` /
  `MO_HELMPASS`) and to the OCI registry.
* Then bump `version` in `mogenius/helm-chart-blueprints/charts/agent-sandbox.yaml`.
