{{- /*
Return if persistence value is volumeClaimTemplate
Usage: 
{{ include "common.helpers.persistence.isPersistentVolumeClaim" .Values.path.to.persistenceDefinition }}
*/ -}}
{{- define "common.helpers.persistence.isPersistentVolumeClaim" -}}
  {{- $mightBeVolumeClaim := or (hasKey (.spec) "accessModes") (hasKey ((.spec).resources) "requests") (hasKey (.spec) "storageClassName") -}}
  {{- if or ((.spec).isVolumeClaimTemplate) ((.spec).isPersistentVolumeClaim) -}}
    {{- print "true" -}}
  {{- else -}}
    {{- ternary "true" "" $mightBeVolumeClaim -}}
  {{- end -}}
{{- end }}

{{- define "common.helpers.persistence.hasPersistentVolumeClaims" -}}
  {{- range $volumeName, $persistence := .Values.persistence -}}
    {{- if and (hasKey ($persistence.spec) "persistentVolumeClaim") (hasKey ($persistence.spec.persistentVolumeClaim) "claimName") -}}
      {{- print "true" -}}
      {{- break -}}
    {{- else if (include "common.helpers.persistence.isPersistentVolumeClaim" $persistence) -}}
      {{- print "true" -}}
      {{- break -}}
    {{- end -}}
  {{- end -}}
{{- end }}
