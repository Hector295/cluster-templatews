{{/*
Expand the name of the chart.
*/}}
{{- define "rke2-baremetal-calico.name" -}}
{{- default .Chart.Name .Values.cluster.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rke2-baremetal-calico.fullname" -}}
{{- if .Values.cluster.name }}
{{- .Values.cluster.name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.cluster.name }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rke2-baremetal-calico.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rke2-baremetal-calico.labels" -}}
helm.sh/chart: {{ include "rke2-baremetal-calico.chart" . }}
{{ include "rke2-baremetal-calico.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rke2-baremetal-calico.selectorLabels" -}}
cluster.x-k8s.io/name: {{ include "rke2-baremetal-calico.name" . }}
cluster.x-k8s.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "rke2-baremetal-calico.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "rke2-baremetal-calico.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Verify if baremetal-operator is running
*/}}
{{- $bmOperator := lookup "apps/v1" "Deployment" "baremetal-operator" "baremetal-operator-controller-manager" }}
{{- if not $bmOperator }}
{{- fail "baremetal-operator-controller-manager deployment not found in baremetal-operator namespace" }}
{{- end }}
{{- if not (and $bmOperator.status.readyReplicas (gt $bmOperator.status.readyReplicas 0)) }}
{{- fail "baremetal-operator-controller-manager deployment exists but is not ready" }}
{{- end }}
