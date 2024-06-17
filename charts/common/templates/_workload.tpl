{{/* Renders workload defined by .Values.workloadType */}}
{{- define "common.workload" -}}
  {{- $workload := include "common.helpers.names.workloadType" . -}}

  {{- if eq $workload "Deployment" }}
    {{- include "common.persistentVolumeClaim" . | nindent 0 }}
    {{- include "common.deployment" . | nindent 0 }}
  {{- else if eq $workload "StatefulSet" }}
    {{- include "common.statefulset" . | nindent 0 }}
  {{- end -}}

{{- end -}}