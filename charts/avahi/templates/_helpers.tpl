{{/*
Expand the name of the chart.
*/}}
{{- define "avahi.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "avahi.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "avahi.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "avahi.labels" -}}
helm.sh/chart: {{ include "avahi.chart" . }}
{{ include "avahi.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "avahi.selectorLabels" -}}
app.kubernetes.io/name: {{ include "avahi.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "avahi.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "avahi.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "avahi.imageTagOrDigest" -}}
{{- if .Values.image.tag -}}
:{{ .Values.image.tag }}
{{- else if .Values.image.digest -}}
@sha256:{{- .Values.image.digest -}}
{{- else -}}
:{{ .Chart.AppVersion }}
{{- end -}}
{{- end }}

{{- define "avahi.envSecret" -}}
{{- if and .Values.env .Values.env.existingSecret -}}
{{- .Values.env.existingSecret -}}
{{- else -}}
{{ include "avahi.fullname" . }}-secret
{{- end -}}
{{- end -}}