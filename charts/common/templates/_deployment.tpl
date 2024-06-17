{{/*
Deployment template
*/}}
{{- define "common.deployment" }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "common.helpers.names.fullname" . }}
  labels:
    {{- include "common.helpers.labels" . | nindent 4 }}
spec:
  {{- if not (.Values.autoscaling).enabled }}
  replicas: {{ .Values.replicaCount | default 1 }}
  {{- end }}
  {{- include "common.tpl.strategy" . | nindent 2 }}
  selector:
    matchLabels:
      {{- include "common.helpers.labels.selectorLabels" . | nindent 6 }}
  template:
    {{- include "common.tpl.pod" . | nindent 4 }}
{{- end }}
