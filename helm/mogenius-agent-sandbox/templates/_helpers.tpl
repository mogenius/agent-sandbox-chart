{{/*
Chart name, truncated to a DNS label.
*/}}
{{- define "mogenius-agent-sandbox.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels for controller objects.
*/}}
{{- define "mogenius-agent-sandbox.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | quote }}
app.kubernetes.io/name: {{ include "mogenius-agent-sandbox.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ include "mogenius-agent-sandbox.controllerTag" . | quote }}
app.kubernetes.io/part-of: agent-sandbox
{{- end }}

{{/*
Selector labels for the controller Deployment and Service. `app` is kept for
compatibility with upstream tooling that selects on it.
*/}}
{{- define "mogenius-agent-sandbox.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mogenius-agent-sandbox.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: agent-sandbox-controller
{{- end }}

{{/*
Controller image tag: explicit tag or the chart's appVersion.
*/}}
{{- define "mogenius-agent-sandbox.controllerTag" -}}
{{- default .Chart.AppVersion .Values.controller.image.tag }}
{{- end }}

{{- define "mogenius-agent-sandbox.controllerImage" -}}
{{- printf "%s:%s" .Values.controller.image.repository (include "mogenius-agent-sandbox.controllerTag" .) }}
{{- end }}

{{/*
Controller arguments, mirroring the upstream manifest plus opt-in extras.
*/}}
{{- define "mogenius-agent-sandbox.controllerArgs" -}}
- --leader-elect={{ .Values.controller.leaderElect }}
{{- if .Values.controller.extensions }}
- --extensions
{{- end }}
{{- range .Values.controller.extraArgs }}
- {{ . | quote }}
{{- end }}
{{- end }}

{{/*
Namespace the sandbox pods live in.
*/}}
{{- define "mogenius-agent-sandbox.sandboxNamespace" -}}
{{- .Values.sandboxes.namespace.name }}
{{- end }}

{{/*
The NetworkPolicy spec body (ingress + egress) rendered into a managed
SandboxTemplate when networkPolicy.explicit is set. Egress allows the internet
minus the toggled blocks (RFC1918, the metadata endpoint, optionally the
apiserver, plus any additionalBlockedCidrs) and keeps DNS reachable.
*/}}
{{- define "mogenius-agent-sandbox.sandboxNetworkPolicy" -}}
{{- $np := .Values.sandboxes.networkPolicy -}}
{{- $except := list -}}
{{- if $np.blockRfc1918 -}}{{- $except = concat $except $np.rfc1918Cidrs -}}{{- end -}}
{{- if $np.blockMetadataEndpoint -}}{{- $except = concat $except $np.metadataCidrs -}}{{- end -}}
{{- if $np.blockApiServer -}}{{- $except = concat $except $np.apiServerCidrs -}}{{- end -}}
{{- if $np.additionalBlockedCidrs -}}{{- $except = concat $except $np.additionalBlockedCidrs -}}{{- end -}}
{{- /*
Scope the policy to Egress unless ingress peers are configured, so enabling it
only tightens egress and leaves the pods' ingress exactly as it was (an egress-
only policy with no policyTypes would otherwise implicitly deny all ingress).
*/ -}}
policyTypes:
  {{- with $np.ingressFrom }}
  - Ingress
  {{- end }}
  - Egress
{{- with $np.ingressFrom }}
ingress:
  - from:
      {{- toYaml . | nindent 6 }}
{{- end }}
egress:
  {{- if $np.allowDns }}
  - ports:
      - protocol: UDP
        port: 53
      - protocol: TCP
        port: 53
  {{- end }}
  - to:
      - ipBlock:
          cidr: 0.0.0.0/0
          {{- with $except }}
          except:
            {{- range . }}
            - {{ . }}
            {{- end }}
          {{- end }}
      {{- with $np.blockedCidrsV6 }}
      - ipBlock:
          cidr: ::/0
          except:
            {{- range . }}
            - {{ . }}
            {{- end }}
      {{- end }}
{{- end }}
