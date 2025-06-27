{{- define "cilium.values" -}}
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-cilium
  namespace: kube-system
spec:
  valuesContent: |-
    MTU: {{ .Values.cniConfig.mtu }}
    tunnelProtocol: {{ .Values.cniConfig.tunnelProtocol }}
    enableIPv4Masquerade: {{ .Values.cniConfig.masquerade }}
    ipam:
      mode: cluster-pool
      operator:
        clusterPoolIPv4PodCIDRList: ["{{ .Values.cniConfig.podCIDR }}"]
    {{- if .Values.cniConfig.additionalConfig }}
        {{- toYaml .Values.cniConfig.additionalConfig | indent 18 }}
    {{- end }}
{{- end }}