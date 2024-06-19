{{- /* Creates service definition. By default StatefulSet workload also creates service, which can be disabled with .Values.service.headless: false */ -}}
{{- define "common.service" }}
  {{- if .Values.service -}}
    {{- $fullName := include "common.helpers.names.fullname" . -}}
    {{- $commonLabels := (include "common.helpers.labels" .) | fromYaml -}}
    {{- $selectorLabels := (include "common.helpers.labels.selectorLabels" .) | fromYaml -}}
    {{- $isSts := eq "StatefulSet" (include "common.helpers.names.workloadType" .) -}}

    {{- range $name, $service := .Values.service -}}
      {{- $createService := true -}}
      {{- if hasKey $service "enabled" -}}
        {{- $createService = $service.enabled -}}
      {{- else if not (hasKey $service "ports") -}}
        {{- $createService = false -}}
      {{- end -}}

      {{- /* Creates headless service copy if is only "main" named service  */ -}}
      {{- $createHeadlessCopy := hasKey $service "createHeadless" | ternary $service.createHeadless (and $isSts (eq "main" $name)) -}}

      {{- $serviceSpec := omit $service "createHeadless" "annotations" "name" "labels" "ports" "enabled" "isStsService" -}}
      {{- $servicePorts := $service.ports -}}
      {{- if not (hasKey $serviceSpec "type") -}}
        {{- $serviceSpec = merge (dict "type" "ClusterIP") $serviceSpec -}}
      {{- end -}}

      {{- $serviceLabels := merge $commonLabels ($service.labels | default dict) -}}

      {{- $serviceSpec = merge (dict "selector" $selectorLabels) $serviceSpec -}}
      {{- $headlessSpec := omit $serviceSpec "type" "clusterIP" -}}
      {{- $serviceName := printf "%s-%s" $fullName ($service.name | default $name) -}}
      {{- if and (not $service.name) (eq "main" $name) -}}
        {{- $serviceName = $fullName -}}
      {{- end -}}
      {{- if $createService }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $serviceName }}
  {{- with $service.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- toYaml $serviceLabels | nindent 4 }}
spec:
  {{- include "common.tpl.ports.service" $service.ports | nindent 2 }}
  {{- toYaml $serviceSpec | nindent 2 }}
        {{- if $createHeadlessCopy }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $serviceName }}-headless
  {{- with $service.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- toYaml $serviceLabels | nindent 4 }}
spec:
  type: ClusterIP
  clusterIP: None
  {{- include "common.tpl.ports.service" $service.ports | nindent 2 }}
  {{- toYaml $headlessSpec | nindent 2 }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
