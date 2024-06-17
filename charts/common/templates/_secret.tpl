{{- define "common.secret" }}
  {{- $fullName := include "common.helpers.names.fullname" . -}}
  {{- $labels := include "common.helpers.labels" . -}}
  {{- range $name, $secret := .Values.secrets -}}
  {{- $name = $secret.name | default $name }}
---
apiVersion: v1
kind: Secret
metadata:
  name: {{ $fullName }}-{{ $name }}
  labels:
    {{- $labels | nindent 4 }}
type: {{ $secret.type | default "Opaque" }}
data:
    {{- range $secretKey, $secretValue := $secret.data }}
      {{- $secretKey | nindent 2 }}: {{ $secretValue | toString | b64enc }}
    {{- end }}
  {{- end }}
{{- end }}