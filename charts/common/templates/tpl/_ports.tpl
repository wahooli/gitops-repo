{{- define "common.tpl.ports.container" -}}
  {{- if .Values.service.ports -}}
ports:
    {{- range $_, $port := .Values.service.ports }}
- name: {{ $port.name | trunc 15 | trimAll "-" }}
  containerPort: {{ $port.containerPort | default $port.port }}
  protocol: {{ $port.protocol | default "TCP" }}
    {{- end -}}
  {{- end -}}
{{- end }}

{{- define "common.tpl.ports.service" -}}
  {{- if .Values.service.ports -}}
ports:
    {{- range $_, $port := .Values.service.ports }}
- name: {{ $port.name | trunc 15 | trimAll "-" }}
  targetPort: {{ $port.name | trunc 15 | trimAll "-" }}
  port: {{ $port.port }}
  protocol: {{ $port.protocol | default "TCP" }}
    {{- end -}}
  {{- end -}}
{{- end }}