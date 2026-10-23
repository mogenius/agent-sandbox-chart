# mogenius-agent-sandbox

![Version: 1.3.1](https://img.shields.io/badge/Version-1.3.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.0.8](https://img.shields.io/badge/AppVersion-v1.0.8-informational?style=flat-square)

Complete agent-sandbox setup for a mogenius cluster: the kubernetes-sigs/agent-sandbox controller with extensions (SandboxTemplate, SandboxClaim, SandboxWarmPool), plus a sandbox namespace, a locked-down runtime ServiceAccount, the default SandboxTemplate and warm pool the SDK claims from, and a per-sandbox NetworkPolicy.

**Homepage:** <https://github.com/kubernetes-sigs/agent-sandbox>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| mogenius |  | <https://github.com/mogenius> |

## Source Code

* <https://github.com/kubernetes-sigs/agent-sandbox>
* <https://github.com/mogenius/agent-sandbox-chart>

## Requirements

Kubernetes: `>=1.25.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| controller.affinity | object | `{}` |  |
| controller.config | object | `{}` |  |
| controller.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| controller.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| controller.containerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| controller.extensions | bool | `true` |  |
| controller.extraArgs | list | `[]` |  |
| controller.image.pullPolicy | string | `"IfNotPresent"` |  |
| controller.image.repository | string | `"registry.k8s.io/agent-sandbox/agent-sandbox-controller"` |  |
| controller.image.tag | string | `""` |  |
| controller.leaderElect | bool | `true` |  |
| controller.metrics.service.enabled | bool | `true` |  |
| controller.nodeSelector | object | `{}` |  |
| controller.podAnnotations | object | `{}` |  |
| controller.podLabels | object | `{}` |  |
| controller.podSecurityContext.runAsNonRoot | bool | `true` |  |
| controller.podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| controller.probes.enabled | bool | `true` |  |
| controller.replicaCount | int | `1` |  |
| controller.resources.limits.memory | string | `"512Mi"` |  |
| controller.resources.requests.cpu | string | `"50m"` |  |
| controller.resources.requests.memory | string | `"128Mi"` |  |
| controller.tolerations | list | `[]` |  |
| sandboxes.namespace.annotations | object | `{}` |  |
| sandboxes.namespace.create | bool | `true` |  |
| sandboxes.namespace.labels | object | `{}` |  |
| sandboxes.namespace.name | string | `"agent-sandbox"` |  |
| sandboxes.networkPolicy.additionalBlockedCidrs | list | `[]` |  |
| sandboxes.networkPolicy.allowDns | bool | `true` |  |
| sandboxes.networkPolicy.apiServerCidrs | list | `[]` |  |
| sandboxes.networkPolicy.blockApiServer | bool | `false` |  |
| sandboxes.networkPolicy.blockMetadataEndpoint | bool | `true` |  |
| sandboxes.networkPolicy.blockRfc1918 | bool | `true` |  |
| sandboxes.networkPolicy.blockedCidrsV6[0] | string | `"fc00::/7"` |  |
| sandboxes.networkPolicy.blockedCidrsV6[1] | string | `"fe80::/10"` |  |
| sandboxes.networkPolicy.explicit | bool | `true` |  |
| sandboxes.networkPolicy.ingressFrom | list | `[]` |  |
| sandboxes.networkPolicy.managed | bool | `true` |  |
| sandboxes.networkPolicy.metadataCidrs[0] | string | `"169.254.0.0/16"` |  |
| sandboxes.networkPolicy.rfc1918Cidrs[0] | string | `"10.0.0.0/8"` |  |
| sandboxes.networkPolicy.rfc1918Cidrs[1] | string | `"172.16.0.0/12"` |  |
| sandboxes.networkPolicy.rfc1918Cidrs[2] | string | `"192.168.0.0/16"` |  |
| sandboxes.runtimeClassName | string | `""` |  |
| sandboxes.service | bool | `true` |  |
| sandboxes.serviceAccount.annotations | object | `{}` |  |
| sandboxes.serviceAccount.create | bool | `true` |  |
| sandboxes.serviceAccount.name | string | `"sandbox-runtime"` |  |
| sandboxes.template.args | list | `[]` |  |
| sandboxes.template.command | list | `[]` |  |
| sandboxes.template.containerExtra | object | `{}` |  |
| sandboxes.template.containerName | string | `"sandbox"` |  |
| sandboxes.template.env[0].name | string | `"ANTHROPIC_API_KEY"` |  |
| sandboxes.template.env[0].valueFrom.secretKeyRef.key | string | `"anthropic-api-key"` |  |
| sandboxes.template.env[0].valueFrom.secretKeyRef.name | string | `"sandbox-provider-keys"` |  |
| sandboxes.template.env[0].valueFrom.secretKeyRef.optional | bool | `true` |  |
| sandboxes.template.env[1].name | string | `"CLAUDE_CODE_OAUTH_TOKEN"` |  |
| sandboxes.template.env[1].valueFrom.secretKeyRef.key | string | `"claude-code-oauth-token"` |  |
| sandboxes.template.env[1].valueFrom.secretKeyRef.name | string | `"sandbox-provider-keys"` |  |
| sandboxes.template.env[1].valueFrom.secretKeyRef.optional | bool | `true` |  |
| sandboxes.template.image | string | `"ghcr.io/mogenius/agent-sandbox-chart/sandbox-default:1.3.1"` |  |
| sandboxes.template.imagePullPolicy | string | `"IfNotPresent"` |  |
| sandboxes.template.name | string | `"default"` |  |
| sandboxes.template.podSecurityContext.fsGroup | int | `1000` |  |
| sandboxes.template.podSpecExtra | object | `{}` |  |
| sandboxes.template.port | int | `8080` |  |
| sandboxes.template.probes.enabled | bool | `true` |  |
| sandboxes.template.probes.path | string | `"/healthz"` |  |
| sandboxes.template.resources.limits.cpu | string | `"2"` |  |
| sandboxes.template.resources.limits.memory | string | `"2Gi"` |  |
| sandboxes.template.resources.requests.cpu | string | `"250m"` |  |
| sandboxes.template.resources.requests.ephemeral-storage | string | `"512Mi"` |  |
| sandboxes.template.resources.requests.memory | string | `"512Mi"` |  |
| sandboxes.template.restartPolicy | string | `"OnFailure"` |  |
| sandboxes.template.runtimeClassName | string | `""` |  |
| sandboxes.template.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| sandboxes.template.securityContext.runAsGroup | int | `1000` |  |
| sandboxes.template.securityContext.runAsNonRoot | bool | `true` |  |
| sandboxes.template.securityContext.runAsUser | int | `1000` |  |
| sandboxes.template.shmSizeLimit | string | `""` |  |
| sandboxes.template.storage.enabled | bool | `true` |  |
| sandboxes.template.storage.mountPath | string | `"/home/coder/project"` |  |
| sandboxes.template.storage.size | string | `"1Gi"` |  |
| sandboxes.template.storage.storageClassName | string | `""` |  |
| sandboxes.warmPool.replicas | int | `1` |  |
| sandboxes.warmPool.updateStrategy | string | `"OnReplenish"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
