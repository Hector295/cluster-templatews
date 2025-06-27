{{- define "calico.values" -}}
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-calico
  namespace: kube-system
spec:
  valuesContent: |-
    installation:
      calicoNetwork:
      {{- if eq .Values.cniConfig.bgp true }}
        bgp: Enabled
      {{- end }}
      {{- if not (hasKey .Values.cniConfig.additionalConfig "mtu") }}
        mtu: {{ .Values.cniConfig.mtu | default 1440 }}
      {{- end }}
      {{- if not (hasKey .Values.cniConfig.additionalConfig "ipPools") }}
        ipPools:
          - cidr: {{ .Values.cniConfig.podCIDR }}
            disableBGPExport: true
            encapsulation: {{ .Values.cniConfig.tunnelProtocol | upper }}
          {{- if eq .Values.cniConfig.masquerade true }}
            natOutgoing: Enabled
          {{- end }}
            nodeSelector: all()
      {{- end }}
      {{- if .Values.cniConfig.additionalConfig }}
        {{- toYaml .Values.cniConfig.additionalConfig | indent 18 }}
      {{- end }}
{{- end }}