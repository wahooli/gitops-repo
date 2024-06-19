{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "common.helpers.names.fullname" -}}
  {{- if .Values.fullnameOverride -}}
    {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
  {{- else -}}
    {{- $name := default .Chart.Name .Values.nameOverride -}}
    {{- if contains $name .Release.Name -}}
      {{- .Release.Name | trunc 63 | trimSuffix "-" }}
    {{- else -}}
      {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
    {{- end -}}
  {{- end -}}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "common.helpers.name" -}}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "common.helpers.names.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/* Returns name of service account, if enabled */}}
{{- define "common.helpers.names.serviceAccount" -}}
  {{- if .Values.serviceAccount.create -}}
    {{- default (include "common.helpers.names.fullname" .) .Values.serviceAccount.name -}}
  {{- else -}}
    {{- default "default" .Values.serviceAccount.name -}}
  {{- end -}}
{{- end }}

{{/* Returns service name, headless if enabled */}}
{{- define "common.helpers.names.stsServiceName" -}}
  {{- $fullName := include "common.helpers.names.fullname" . -}}
  {{- $stsServiceName := "" -}}
  {{- range $name, $service := .Values.service -}}
    {{- $serviceName := $service.name | default $name -}}
    {{- if and (eq "" $stsServiceName) $service.isStsService -}}
      {{- $stsServiceName = $serviceName -}}
    {{- end -}}
  {{- end -}}
  {{- /* try defaulting to main service, if stsService boolean is undefined for any service */ -}}
  {{- if and (eq "" $stsServiceName) (.Values.service).main -}}
    {{- $serviceName := (.Values.service.main).name | default "main" -}}
  {{- end -}}
  {{- if ne "" $stsServiceName -}}
    {{- printf "%s-%s" $fullName $stsServiceName -}}
  {{- end -}}
{{- end }}

{{/* Return the workload type, defaults to "Deployment" */}}
{{- define "common.helpers.names.workloadType" -}}
  {{- if .Values.workloadType -}}
    {{- if eq (lower .Values.workloadType) "deployment" -}}
      {{- print "Deployment" -}}
    {{- else if eq (lower .Values.workloadType) "statefulset"  -}}
      {{- print "StatefulSet" -}}
    {{- else -}}
      {{- fail (printf "Not a valid workloadType (%s)" .Values.workloadType) -}}
    {{- end -}}
  {{- else -}}
    {{- print "Deployment" -}}
  {{- end -}}
{{- end -}}

{{/* 
Return configMap name
* first param is root, required
* second param is the name of configmap, returns modified value if chart has configmap with same name
* third param is boolean, if false returns second parameter unmodified

usage: {{ include "common.helpers.names.configMapName" ( list $ [name of configmap] [true|false]) }}
*/}}
{{- define "common.helpers.names.configMapName" -}}
  {{- $root := index . 0 -}}
  {{- $name := index . 1 -}}
  {{- $useConfigMapFromChart := index . 2 -}}
  {{- $fullName := include "common.helpers.names.fullname" $root -}}
  {{- $names := list -}}
  {{- if $useConfigMapFromChart -}}
    {{- range $name, $configMap := $root.Values.configMaps -}}
      {{- $names = append $names ($configMap.name | default $name) -}}
    {{- end -}}
    {{- if has $name $names -}}
      {{- $name = printf "%s-%s" $fullName $name -}}
    {{- end -}}
  {{- end -}}
  {{- $name -}}
{{- end }}

{{/* 
Return secret name
* first param is root, required
* second param is the name of secret, returns modified value if chart has secret with same name
* third param is boolean, if false returns second parameter unmodified

usage: {{ include "common.helpers.names.secretName" ( list $ [name of secret] [true|false]) }}
*/}}
{{- define "common.helpers.names.secretName" -}}
  {{- $root := index . 0 -}}
  {{- $name := index . 1 -}}
  {{- $useSecretFromChart := index . 2 -}}
  {{- $fullName := include "common.helpers.names.fullname" $root -}}
  {{- $names := list -}}
  {{- if $useSecretFromChart -}}
    {{- range $name, $secret := $root.Values.secrets -}}
      {{- $names = append $names ($secret.name | default $name) -}}
    {{- end -}}
    {{- if has $name $names -}}
      {{- $name = printf "%s-%s" $fullName $name -}}
    {{- end -}}
  {{- end -}}
  {{- $name -}}
{{- end }}

{{/* 
Return pvc name
* first param is root, required
* second param is the name of persistence object, returns modified value if third param isn't false
* third param is boolean, if false returns second parameter unmodified

usage: {{ include "common.helpers.names.persistentVolumeClaimName" ( list $ [name of pvc] [true|false]) }}
*/}}
{{- define "common.helpers.names.persistentVolumeClaimName" -}}
  {{- $root := index . 0 -}}
  {{- $name := index . 1 -}}
  {{- $useFromChart := index . 2 -}}
  {{- if $useFromChart -}}
    {{- $fullName := include "common.helpers.names.fullname" $root -}}
    {{- $name = printf "%s-%s" $name $fullName -}}
  {{- end -}}
  {{- $name -}}
{{- end }}