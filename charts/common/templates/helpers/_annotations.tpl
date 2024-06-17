{{/*
Contains .Values.podAnnotations with envSecret template checksum
*/}}
{{- define "common.helpers.annotations.podAnnotations" -}}
  {{- $podAnnotations := .Values.podAnnotations -}}
  {{- if .Values.secrets -}}
    {{- $podAnnotations = merge $podAnnotations (dict "checksum/secrets" (.Values.secrets | toYaml | sha256sum)) -}}
  {{- end -}}
  {{- if .Values.configMaps -}}
    {{- $podAnnotations = merge $podAnnotations (dict "checksum/configMaps" (.Values.configMaps | toYaml | sha256sum)) -}}
  {{- end -}}
  {{- with $podAnnotations -}}
annotations:
    {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}