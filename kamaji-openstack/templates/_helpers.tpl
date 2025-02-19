{{/*
Expand the name of the chart.
*/}}
{{- define "kamaji-openstack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kamaji-openstack.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
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
{{- define "kamaji-openstack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kamaji-openstack.labels" -}}
helm.sh/chart: {{ include "kamaji-openstack.chart" . }}
{{ include "kamaji-openstack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kamaji-openstack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kamaji-openstack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kamaji-openstack.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kamaji-openstack.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "cloudConfig.innerSecret" -}}
apiVersion: v1
kind: Secret
metadata:
  name: cloud-config
  namespace: kube-system
data:
  cloud.conf:
    {{- $password := (lookup "v1" "Secret" .Values.cloudCredentials.password.secretNamespace .Values.cloudCredentials.password.secretName).data.password | b64dec }}
    {{- $config := printf "[Global]\nauth-url=%s\nusername=%s\npassword=%s\nregion=%s\ntenant-name=%s\ndomain-name=%s\n" .Values.cloudCredentials.authUrl .Values.cloudCredentials.username $password .Values.cloudCredentials.region .Values.cloudCredentials.project .Values.cloudCredentials.domain }}
    {{- $config := $config | b64enc }}
    {{- $config := cat " " $config }}
    {{- $config }}
{{- end }}