{{- /* Creates service definition. By default StatefulSet workload also creates service, which can be disabled with .Values.service.headless: false */ -}}
{{- define "common.service" }}
  {{- $createService := true -}}
  {{- if hasKey .Values.service "create" -}}
    {{- $createService = .Values.service.create -}}
  {{- else if not (hasKey .Values.service "ports") -}}
    {{- $createService = false -}}
  {{- end -}}
  {{- if $createService -}}
    {{- $isSts := eq "StatefulSet" (include "common.helpers.names.workloadType" .) -}}
    {{- $headlessSvcEnabled := hasKey .Values.service "headless" | ternary .Values.service.headless $isSts -}}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common.helpers.names.fullname" . }}
  labels:
    {{- include "common.helpers.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type | default "ClusterIP" }}
  {{- include "common.tpl.ports.service" . | nindent 2 }}
  selector:
    {{- include "common.helpers.labels.selectorLabels" . | nindent 4 }}
  {{- if $headlessSvcEnabled }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common.helpers.names.fullname" . }}-headless
  labels:
    {{- include "common.helpers.labels" . | nindent 4 }}
    app.kubernetes.io/component: headless
spec:
  type: ClusterIP
  clusterIP: None
  {{- include "common.tpl.ports.service" . | nindent 2 }}
  selector:
    {{- include "common.helpers.labels.selectorLabels" . | nindent 4 }}
  {{- end -}}
{{- end }}
{{- end }}