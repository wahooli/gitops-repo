{{- define "common.tpl.initContainers" }}
  {{- $initContainers := list -}}
  {{- range $name, $initContainer := .Values.initContainers -}}
    {{- $initContainers = append $initContainers (merge $initContainer (dict "name" $name)) -}}
  {{- end -}}
  {{- if $initContainers -}}
initContainers:
{{ toYaml $initContainers }}
  {{- end }}
{{- end }}