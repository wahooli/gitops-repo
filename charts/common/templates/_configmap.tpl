{{- define "common.configMap" }}
  {{- $fullName := include "common.helpers.names.fullname" . -}}
  {{- $labels := include "common.helpers.labels" . -}}
  {{- range $name, $configMap := .Values.configMaps -}}
  {{- $name = $configMap.name | default $name }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $fullName }}-{{ $name }}
  labels:
    {{- $labels | nindent 4 }}
data:
    {{- range $configKey, $configValue := $configMap.data }}
      {{- $configKey | nindent 2 }}: |-
      {{- (tpl $configValue $) | nindent 4 }}
    {{- end }}
  {{- end }}
{{- end }}