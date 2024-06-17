{{/*
Template for pvc. Used mostly with deployments
*/}}
{{- define "common.persistentVolumeClaim" }}
  {{- $volumeClaimTemplates := list -}}
  {{- $root := . -}}
  {{- $volumeNames := list -}}
  {{- range $volumeName, $persistence := .Values.persistence -}}
    {{- $volumeName = ($persistence).name | default $volumeName -}}
    {{- if has $volumeName $volumeNames -}}
      {{- fail (printf "\"%s\" persistence items cannot have duplicate names!" $volumeName) -}}
    {{- end -}}
    {{- $volumeNames = append $volumeNames $volumeName -}}
    {{- $isPersistentVolumeClaim := include "common.helpers.persistence.isPersistentVolumeClaim" $persistence -}}
    {{- $useFromChart := or ($persistence.spec).useFromChart (not (hasKey ($persistence.spec) "useFromChart")) -}}
    {{- if and (($persistence).enabled | default true) $isPersistentVolumeClaim $useFromChart -}}
      {{- $spec := omit $persistence.spec "useFromChart" "isVolumeClaimTemplate" "isPersistentVolumeClaim" -}}
      {{- $pvcName := include "common.helpers.names.persistentVolumeClaimName" ( list $root $volumeName $useFromChart ) }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ $pvcName }}
  annotations:
    helm.sh/resource-policy: keep
  labels:
      {{- include "common.helpers.labels.podLabels" $root | nindent 4 -}}
      {{- if (($persistence).labels) }}
        {{- $persistence.labels | toYaml | nindent 4 }}
      {{- end }}
spec:
      {{- toYaml $spec | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}