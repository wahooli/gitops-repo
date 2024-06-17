{{- define "common.tpl.probes" -}}
  {{- range $probeType, $probe := .Values.probe -}}
    {{- $failureThresholdDefault := eq "startup" ($probeType | lower) | ternary 30 10 -}}
    {{- $successThreshold := eq "readiness" ($probeType | lower) | ternary $probe.successThreshold 1 -}}
    {{- $probeEnabled := hasKey $probe "enabled" | ternary $probe.enabled true }}
    {{- if $probeEnabled }}
{{ $probeType | lower }}Probe:
      {{- if $probe.exec }}
  exec:
        {{- $probe.exec | toYaml | nindent 4 }}
      {{- else if $probe.httpGet }}
  httpGet:
        {{- $probe.httpGet | toYaml | nindent 4 }}
      {{- else if $probe.tcpSocket }}
  tcpSocket:
        {{- $probe.tcpSocket | toYaml | nindent 4 }}
      {{- else if $probe.grpc }}
  grpc:
        {{- $probe.grpc | toYaml | nindent 4 }}
      {{- else -}}
        {{- $probeType | printf "%sProbe doesn't have command, http request, tcpSocket or grpc probe defined!" | fail -}}
      {{- end }}
  initialDelaySeconds: {{ $probe.initialDelaySeconds | default 0 }}
  periodSeconds: {{ $probe.periodSeconds | default 10 }}
  timeoutSeconds: {{ $probe.timeoutSeconds | default 1 }}
  successThreshold: {{ $successThreshold | default 1 }}
  failureThreshold: {{ $probe.failureThreshold | default $failureThresholdDefault }}
    {{- end -}}
  {{- end -}}
{{- end }}