{{- define "common.tpl.pod" }}
metadata:
  {{- include "common.helpers.annotations.podAnnotations" . | nindent 2 }}
  labels:
    {{- include "common.helpers.labels.podLabels" . | nindent 4 }}
spec:
  {{- with .Values.imagePullSecrets }}
  imagePullSecrets:
    {{- toYaml . | nindent 2 }}
  {{- end }}
  {{- with .Values.runtimeClassName }}
  runtimeClassName: {{ toYaml . }}
  {{- end }}
  {{- with .Values.priorityClassName }}
  priorityClassName: {{ toYaml . }}
  {{- end }}
  {{- with (.Values.restartPolicy | default "Always") }}
  restartPolicy: {{ toYaml . }}
  {{- end }}
  serviceAccountName: {{ include "common.helpers.names.serviceAccount" . }}
  dnsPolicy: {{ .Values.dnsPolicy | default "ClusterFirst" }}
  {{- with .Values.hostname }}
  hostname: {{ toYaml . }}
  {{- end }}
  {{- with .Values.subdomain }}
  subdomain: {{ toYaml . }}
  {{- end }}
  securityContext:
    {{- toYaml .Values.podSecurityContext | nindent 4 }}
  {{- include "common.tpl.initContainers" . | nindent 2 }}
  containers:
  - name: {{ .Chart.Name }}
    securityContext:
      {{- toYaml .Values.securityContext | nindent 6 }}
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
    imagePullPolicy: {{ .Values.image.pullPolicy }}
    {{- include "common.tpl.env" . | nindent 4 -}}
    {{- include "common.tpl.env.envFrom" . | nindent 4 -}}
    {{- with .Values.command }}
    command:
      {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- with .Values.args }}
    args:
      {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- include "common.tpl.volumeMounts" . | nindent 4 -}}
    {{- include "common.tpl.probes" . | nindent 4 }}
    {{- include "common.tpl.ports.container" . | nindent 4 }}
    resources:
      {{- toYaml .Values.resources | nindent 6 }}
  {{- with .Values.nodeSelector }}
  nodeSelector:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.affinity }}
  affinity:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.tolerations }}
  tolerations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- include "common.tpl.volumes" . | nindent 2 -}}
{{- end }}