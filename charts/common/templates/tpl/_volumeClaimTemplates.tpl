{{- define "common.tpl.volumeClaimTemplates" -}}
  {{- $volumeClaimTemplates := list -}}
  {{- $volumeNames := list -}}
  {{- range $volumeName, $persistence := .Values.persistence -}}
    {{- $volumeName = ($persistence).name | default $volumeName -}}
    {{- if has $volumeName $volumeNames -}}
      {{- fail (printf "\"%s\" volume cannot be declared more than once!" $volumeName) -}}
    {{- end -}}
    {{- $volumeNames = append $volumeNames $volumeName -}}

    {{- /* 
      add name key into persistence object
    */ -}}
    {{- $persistence = merge (dict "name" $volumeName) $persistence -}}
    {{- if and (($persistence).enabled | default true) (include "common.helpers.persistence.isPersistentVolumeClaim" $persistence) -}}
      {{- $volumeClaimTemplate := include "common.tpl.volumeClaimTemplates.volumeClaimTemplate" (dict "root" $ "persistence" $persistence) -}}
      {{- if $volumeClaimTemplate -}}
        {{- $volumeClaimTemplates = append $volumeClaimTemplates ($volumeClaimTemplate | fromYaml) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if $volumeClaimTemplates -}}
volumeClaimTemplates:
{{ $volumeClaimTemplates | toYaml }}
  {{- end -}}
{{- end }}

{{/*
Renders single volumeClaimTemplate definition for workload
usage:
{{ include "common.tpl.volumeClaimTemplates.volumeClaimTemplate" ( dict "root" $ "persistence" .Values.path.to.persistenceDefinition) }}
*/}}
{{- define "common.tpl.volumeClaimTemplates.volumeClaimTemplate" -}}
  {{- $name := required ".Values.persistence items require \"name\" key!" .persistence.name -}}
  {{- $spec := omit .persistence.spec "isVolumeClaimTemplate" "isPersistentVolumeClaim" -}}

  {{- if (include "common.helpers.persistence.isPersistentVolumeClaim" .persistence) }}
metadata:
  name: {{ $name }}
  labels:
    {{- include "common.helpers.labels.podLabels" .root | nindent 4 -}}
    {{- if ((.persistence).labels) }}
      {{- .persistence.labels | toYaml | nindent 4 }}
    {{- end }}
spec:
  {{- $spec | toYaml | nindent 2 }}
  {{- end -}}
{{- end }}