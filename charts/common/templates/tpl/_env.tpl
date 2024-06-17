{{- define "common.tpl.env" -}}
  {{- $envs := list -}}
  {{- range $name, $env := .Values.env -}}
    {{- if kindIs "map" $env -}}
      {{- $envs = append $envs (merge (dict "name" $name) $env) -}}
    {{- else -}}
      {{- $envs = append $envs (dict "name" $name "value" ($env | toString)) -}}
    {{- end -}}
  {{- end -}}
  {{- if $envs -}}
env:
{{ toYaml $envs }}
  {{- end }}
{{- end }}

{{- define "common.tpl.env.envFrom" -}}
  {{- $envsFrom := list -}}
  {{- range $name, $envFrom := .Values.envFrom -}}
    {{- $ref := false -}}
    {{- $useFromChart := or $envFrom.useFromChart (not (hasKey $envFrom "useFromChart")) -}}
    {{- if eq ($envFrom).type "secret" -}}
      {{- $secretName := include "common.helpers.names.secretName" ( list $ (($envFrom).name | default $name) $useFromChart ) }}
      {{- $ref = dict "secretRef" (dict "name" $secretName) -}}

    {{- else if eq ($envFrom).type "configMap" -}}
      {{- $configMapName := include "common.helpers.names.configMapName" ( list $ (($envFrom).name | default $name) $useFromChart ) }}
      {{- $ref = dict "configMapRef" (dict "name" $configMapName) -}}
      
    {{- end -}}
    {{- if $ref -}}
      {{- $envsFrom = append $envsFrom $ref -}}
    {{- end -}}
  {{- end -}}
  {{- if $envsFrom -}}
envFrom:
{{ toYaml $envsFrom }}
  {{- end }}
{{- end }}