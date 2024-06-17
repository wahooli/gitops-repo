{{/* Selector labels */}}
{{- define "common.helpers.labels.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common.helpers.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Common labels */}}
{{- define "common.helpers.labels" -}}
helm.sh/chart: {{ include "common.helpers.names.chart" . }}
{{ include "common.helpers.labels.selectorLabels" . }}
  {{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
  {{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
  {{- with (.Values.global).labels }}
    {{- range $k, $v := . }}
      {{- $name := $k }}
      {{- $value := tpl $v $ }}
{{ $name }}: {{ quote $value }}
    {{- end }}
  {{- end }}
{{- end }}


{{- define "common.helpers.labels.podLabels" -}}
  {{- include "common.helpers.labels.selectorLabels" . }}
  {{- with (.Values.global).labels }}
    {{- range $k, $v := . }}
      {{- $name := $k }}
      {{- $value := tpl $v $ }}
{{ $name }}: {{ quote $value }}
    {{- end }}
  {{- end }}
{{- end }}