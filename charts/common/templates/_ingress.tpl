{{/* Ingress template */}}
{{- define "common.ingress" }}
  {{- if .Values.ingress -}}
  {{- $fullName := include "common.helpers.names.fullname" . -}}
  {{- $commonLabels := include "common.helpers.labels" . -}}
  {{- $services := .Values.service -}}
  {{- $kubeVersion := .Capabilities.KubeVersion.GitVersion -}}
  {{- $apiVersion := "extensions/v1beta1" -}}
  {{- if semverCompare ">=1.19-0" $kubeVersion -}}
    {{- $apiVersion = "networking.k8s.io/v1" -}}
  {{- else if semverCompare ">=1.14-0" $kubeVersion -}}
    {{- $apiVersion = "networking.k8s.io/v1beta1" -}}
  {{- end -}}
  {{- range $name, $ingress := .Values.ingress -}}
    {{- if and (kindIs "map" $ingress) ($ingress).enabled -}}
      {{- $defaultPort := false -}}
      {{- $serviceKey := "main" }}
      {{- $portName := "http" -}}
      {{- if $ingress.targetSelector -}}
        {{- $serviceKey = $ingress.targetSelector | keys | first -}}
        {{- $portName = index $ingress.targetSelector $serviceKey -}}
        {{- /* Selector can accept port number also */ -}}
        {{- if kindIs "float64" $portName -}}
          {{- $defaultPort = $portName -}}
        {{- end -}}
      {{- end -}}

      {{- $serviceName := printf "%s-%s" $fullName $serviceKey -}}
      {{- if eq "main" $serviceKey -}}
        {{- $serviceName = $fullName -}}
      {{- end -}}
      {{- if hasKey $services $serviceKey -}}
        {{- $service := index $services $serviceKey -}}
        {{- if ($service).name -}}
          {{- $serviceName = printf "%s-%s" $fullName $service.name -}}
        {{- end -}}
        {{- if and ($service).ports (not $defaultPort) -}}
          {{- range $_, $port := $service.ports -}}
            {{- if eq $port.name $portName -}}
              {{- $defaultPort = $port.containerPort | default $port.port -}}
            {{- end -}}
          {{- end -}}
        {{- else -}}
          {{- fail (printf ".Values.service.%s.ports undefined!" $serviceKey) -}}
        {{- end -}}
      {{- else -}}
        {{- fail (printf "Service: %s is not defined under .Values.service!" $serviceKey) -}}
      {{- end -}}
      {{- $name = $ingress.name | default $name -}}
      {{- $ingressName := $fullName -}}
      {{- if ne "main" $name -}}
        {{- $ingressName = printf "%s-%s" $fullName $name -}}
      {{- end -}}
      {{- if and $ingress.className (not (semverCompare ">=1.18-0" $kubeVersion)) }}
        {{- if not (hasKey $ingress.annotations "kubernetes.io/ingress.class") }}
          {{- $_ := set $ingress.annotations "kubernetes.io/ingress.class" $ingress.className}}
        {{- end }}
      {{- end }}
---
apiVersion: {{ $apiVersion }}
kind: Ingress
metadata:
  name: {{ $ingressName }}
  labels:
    {{- $commonLabels | nindent 4 }}
    {{- with $ingress.labels }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if and $ingress.className (semverCompare ">=1.18-0" $kubeVersion) }}
  ingressClassName: {{ $ingress.className }}
  {{- end }}
  {{- if $ingress.tls }}
  tls:
    {{- range $ingress.tls }}
    - hosts:
      {{- range .hosts }}
      - {{ . | quote }}
      {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range $ingress.hosts -}}
    {{- $hostPort := .servicePort | default $defaultPort -}}
    {{- if not $hostPort -}}
      {{- fail "Could not determine ingress port!" -}}
    {{- end }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          {{- $svcName := .serviceName | default $serviceName }}
          - path: {{ .path }}
            {{- if and .pathType (semverCompare ">=1.18-0" $kubeVersion) }}
            pathType: {{ .pathType }}
            {{- end }}
            backend:
              {{- if hasKey . "service" }}
              service:
                {{- .service | toYaml | nindent 16 }}
              {{- else if semverCompare ">=1.19-0" $kubeVersion }}
              service:
                name: {{ $svcName }}
                port:
                  number: {{ $hostPort }}
              {{- else }}
              serviceName: {{ $svcName }}
              servicePort: {{ $hostPort }}
              {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end -}}
  {{- end -}}
{{- end }}