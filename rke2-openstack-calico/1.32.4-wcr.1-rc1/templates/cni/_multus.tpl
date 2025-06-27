{{- define "multus.enabled.bysriov" -}}
{{- if and .Values.sriovOperator.enabled (not .Values.cniConfig.multusEnabled) -}}
true
{{- else -}}
false
{{- end -}}
{{- end }}

{{- define "multus.values" -}}
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
   name: rke2-multus
   namespace: kube-system
spec:
  valuesContent: |-
    rke2-whereabouts:
      enabled: true
{{- end }}