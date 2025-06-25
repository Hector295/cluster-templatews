{{- define "kubernetes-power-manager.shared-workload" -}}
{{- if .Values.kubernetesPowerManager.enabled }}
  {{- /* Vendor Validation */}}
  {{- $apiRefName := dict "intel" "intel" "amd" "amdepyc" | get .Values.kubernetesPowerManager.baremetalVendor }}
  {{- if not $apiRefName }}
    {{- fail (printf "Invalid 'baremetalVendor': '%s'. Must be 'intel' or 'amd'" .Values.kubernetesPowerManager.baremetalVendor) }}
  {{- end }}

  {{- /* Process Nodes */}}
  {{- range .Values.workerNodes.nodes }}
    {{- $reservedCPUs := .reservedSystemCPU | default $.Values.workerNodes.defaults.reservedSystemCPU }}
    {{- if $reservedCPUs }}
      {{- /* Type Validation */}}
      {{- if not (kindIs "slice" $reservedCPUs) }}
        {{- fail (printf "'reservedSystemCPU' must be a list (node: %s)" (default "unknown" .hostname)) }}
      {{- end }}
---
apiVersion: "power.{{ $apiRefName }}.com/v1"
kind: PowerWorkload
metadata:
  name: shared-{{ .hostname }}-workload
  {{- if eq "intel" $apiRefName }}
  namespace: intel-power
  {{- else }}
  namespace: power-manager
  {{- end }}
spec:
  name: "shared-{{ .hostname }}-workload"
  allCores: true
  reservedCPUs:
  {{- toYaml $reservedCPUs | nindent 4 }}
  powerNodeSelector:
    kubernetes.io/hostname: {{ .hostname | quote }}
  powerProfile: "shared"
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}