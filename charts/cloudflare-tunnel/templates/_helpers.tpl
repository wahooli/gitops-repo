{{/*
Render config if set
*/}}
{{- define "cloudflare-tunnel.config" -}}
  {{- if (.Values).config -}}
    {{- $config := .Values.config -}}
    {{- /* add defaults to config if not defined */ -}}
    {{- range $key, $val := (dict "no-autoupdate" true "metrics" "0.0.0.0:2000" ) -}}
      {{- if not (hasKey $config $key) -}}
        {{- $config = dict $key $val | merge $config -}}
      {{- end -}}
    {{- end }}
    {{- toYaml $config -}}
  {{- end -}}
{{- end }}
