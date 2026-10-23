# Changelog

## [1.3.1](https://github.com/mogenius/agent-sandbox-chart/compare/1.3.0...1.3.1) (2026-10-23)


### Bug Fixes

* **deps:** update ghcr.io/anomalyco/opencode docker tag to v2.1.4 ([af4e89d](https://github.com/mogenius/agent-sandbox-chart/commit/af4e89d1d4ca56a8a982bff1e02ee171520e64bd))
* **sandboxtemplate:** set CRD-defaulted fields explicitly to avoid Argo CD drift ([ac0d93e](https://github.com/mogenius/agent-sandbox-chart/commit/ac0d93ef0dd3648a333db9e339d38ab1b92706a9))

## [1.3.0](https://github.com/mogenius/agent-sandbox-chart/compare/1.2.1...1.3.0) (2026-10-23)


### Features

* **chart:** single default SandboxTemplate + hardened NetworkPolicy ([732a244](https://github.com/mogenius/agent-sandbox-chart/commit/732a244a4ce3b5b3a339a1fb00049f480b1960d8))
* **chart:** single default SandboxTemplate + hardened NetworkPolicy ([078b26b](https://github.com/mogenius/agent-sandbox-chart/commit/078b26b61e7721708f1ada4326bf306d4c7f8e86))
* claude-code in the sandbox-opencode image ([b5f65b8](https://github.com/mogenius/agent-sandbox-chart/commit/b5f65b877999b91d0e4518e008b232d628214f49))
* **deps:** update alpine docker tag to v3.24 ([b7bb454](https://github.com/mogenius/agent-sandbox-chart/commit/b7bb45487f4f01db70a45aed4b9a83c49497f0af))
* **deps:** update codercom/code-server docker tag to v4.141.0 ([7a48405](https://github.com/mogenius/agent-sandbox-chart/commit/7a48405b5ef8dc4660451e9a966ea2bb94255f24))
* **deps:** update ghcr.io/anomalyco/opencode docker tag to v2.1.3 ([a6e8e25](https://github.com/mogenius/agent-sandbox-chart/commit/a6e8e25ebaededc40602734e4a7bcc76e25d1a3a))
* **deps:** update ghcr.io/anomalyco/opencode docker tag to v2.1.3 ([4b4d1bc](https://github.com/mogenius/agent-sandbox-chart/commit/4b4d1bcf62b57c1ce25c87770ee8e345e951798d))


### Bug Fixes

* build and publish the sandbox-opencode image with each release; platform-test profile with a sandbox image for browser-based platform tests; platform-test profile with a sandbox image for browser-based platform tests ([8eebbf9](https://github.com/mogenius/agent-sandbox-chart/commit/8eebbf93b54b509468d60b5fc2e135da55a815d3))
* **chart:** drop policyTypes from SandboxTemplate networkPolicy ([d685f36](https://github.com/mogenius/agent-sandbox-chart/commit/d685f3653b0337f2c248ce319aa001df6e5e907e))
* **deps:** update dependency kubernetes-sigs/agent-sandbox to v1.0.6 ([45bfce9](https://github.com/mogenius/agent-sandbox-chart/commit/45bfce9e118c5f3fd4e0505431fef49ca9f0d1ed))
* **deps:** update dependency kubernetes-sigs/agent-sandbox to v1.0.7 ([7ca5e2e](https://github.com/mogenius/agent-sandbox-chart/commit/7ca5e2edf0b230f68441763604749cab5c137258))
* **deps:** update dependency kubernetes-sigs/agent-sandbox to v1.0.8 ([891159f](https://github.com/mogenius/agent-sandbox-chart/commit/891159f7a26a96df46c7a35b77bc4147e996b1d6))
* **deps:** update dependency kubernetes-sigs/agent-sandbox to v1.0.8 ([d3320fd](https://github.com/mogenius/agent-sandbox-chart/commit/d3320fd726ff6c18b78b72fe55d221b519996bd3))
* **deps:** update ghcr.io/anomalyco/opencode docker tag to v2.0.26 ([e16630a](https://github.com/mogenius/agent-sandbox-chart/commit/e16630ad3e0df33107a8bf337a29791ed7005a8a))
* **deps:** update ghcr.io/anomalyco/opencode docker tag to v2.0.27 ([b843de9](https://github.com/mogenius/agent-sandbox-chart/commit/b843de98c43a0188cbc7db1c414c2abf1fb85fbf))
* **deps:** update ghcr.io/anomalyco/opencode docker tag to v2.0.32 ([964a415](https://github.com/mogenius/agent-sandbox-chart/commit/964a415d66503b86c22a196c0a80c9883c62df83))

## [1.2.1](https://github.com/mogenius/agent-sandbox-chart/compare/1.2.0...1.2.1) (2026-09-28)


### Bug Fixes

* **deps:** update dependency kubernetes-sigs/agent-sandbox to v1.0.4 ([d4ab02f](https://github.com/mogenius/agent-sandbox-chart/commit/d4ab02f389c706b3e2209a71a9c0860e4f274d51))
* pin opencode to specific version ([e337a6e](https://github.com/mogenius/agent-sandbox-chart/commit/e337a6e970ca2265267e0c8a2fc89310f80179fe))
* upgrade opencode back to version it was when it was latest ([9fdedb0](https://github.com/mogenius/agent-sandbox-chart/commit/9fdedb0e1e2648f23d2591c5a1719cce2aad68cc))

## [1.2.0](https://github.com/mogenius/agent-sandbox-chart/compare/1.1.6...1.2.0) (2026-09-23)


### Features

* adding release please and renovate ([e85f6a0](https://github.com/mogenius/agent-sandbox-chart/commit/e85f6a04de05a3eacac0259ad295c0cbcf16c2a2))
* mogenius-agent-sandbox chart and default sandbox image ([13ec921](https://github.com/mogenius/agent-sandbox-chart/commit/13ec92110fffbde6b4165adceae70eea1fda2f76))


### Bug Fixes

* release and build process ([ad42b34](https://github.com/mogenius/agent-sandbox-chart/commit/ad42b3479aafc9a36283d3cf260c086354177868))
