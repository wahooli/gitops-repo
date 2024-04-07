{{- define "common.tpl.volumeMounts" -}}
  {{- $volumeMounts := list -}}
  {{- range $name, $persistence := .Values.persistence -}}
    {{- $name = ($persistence).name | default $name -}}
    {{- if and (($persistence).enabled | default true) $persistence.mount -}}
      {{- range $_, $mount := $persistence.mount -}}
        {{- $mountPath := $mount.path | default $mount.mountPath -}}
        {{- if not $mountPath -}}
          {{- fail ".Values.persistence[].mount items require \"path\" or \"mountPath\" keys!" -}}
        {{- end -}}
        {{- $mount = omit $mount "path" "mountPath" -}}
        {{- $mount = merge (dict "name" $name "mountPath" $mountPath) $mount -}}
        {{- $volumeMounts = append $volumeMounts $mount -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if $volumeMounts -}}
volumeMounts:
{{ $volumeMounts | toYaml }}
  {{- end -}}
{{- end }}
