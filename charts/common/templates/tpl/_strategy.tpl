{{- define "common.tpl.strategy" -}}
  {{- $workloadType := include "common.helpers.names.workloadType" . -}}
  {{- $hasPersistentVolumeClaims := false -}}
  {{- if (include "common.helpers.persistence.hasPersistentVolumeClaims" .) -}}
    {{- $hasPersistentVolumeClaims = true -}}
  {{- end -}}
  {{- if ne "Deployment" $workloadType -}}
    {{- include "common.tpl.strategy.updateStrategy" . -}}
  {{- else }}
strategy:
    {{- include "common.tpl.strategy.spec" (list .Values.strategy $workloadType $hasPersistentVolumeClaims) | nindent 2 }}
  {{- end -}}
{{- end }}

{{- define "common.tpl.strategy.updateStrategy" -}}
  {{- $workloadType := include "common.helpers.names.workloadType" . -}}
  {{- $updateStrategySpec := (hasKey .Values "updateStrategy") | ternary .Values.updateStrategy .Values.strategy }}
updateStrategy:
    {{- include "common.tpl.strategy.spec" (list $updateStrategySpec $workloadType false) | nindent 2 }}
{{- end }}

{{/* 
Render deploymentStrategy / updateStrategy
* first param is strategySpec
* second param is the workloadType
* third param is boolean, does the workload contain persistentVolumeClaims

usage: {{ include "common.tpl.strategy.spec" ( list .Values.path.to.strategy/updateStrategy [workloadType] [true/false]) }}
*/}}
{{- define "common.tpl.strategy.spec" -}}
  {{- $spec := index . 0 | default dict -}}
  {{- $workloadType := index . 1 -}}
  {{- $hasPersistentVolumeClaims := index . 2 -}}
  {{- $forceType := ($spec).forceType | default false -}}
  {{- $spec = omit $spec "forceType" -}}
  {{- /* set default spec.type if not defined */ -}}
  {{- if not ($spec).type -}}
    {{- $spec = merge $spec (dict "type" (ternary "Recreate" "RollingUpdate" (and (eq "Deployment" $workloadType) $hasPersistentVolumeClaims))) -}}
  {{- else if not $forceType -}}
    {{- if eq "Deployment" $workloadType -}}
      {{- if and $hasPersistentVolumeClaims (ne "Recreate" $spec.type) -}}
        {{- fail "Recreate is recommended strategy for Deployments with persistent volumes. You can override this warning by setting .Values.strategy.forceType to true" -}}
      {{- else if and (ne "RollingUpdate" $spec.type) (ne "Recreate" $spec.type) -}}
        {{- fail (printf "Unknown stategy type for %s (%s). You can override this warning by setting .Values.strategy.forceType to true" $workloadType $spec.type) -}}
      {{- end -}}
    {{- else if and (ne "RollingUpdate" $spec.type) (ne "OnDelete" $spec.type) -}}
      {{- fail (printf "Unknown stategy type for %s (%s). You can override this warning by setting .Values.strategy.forceType to true" $workloadType $spec.type) -}}
    {{- end -}}
  {{- end -}}
  {{- toYaml $spec -}}
{{- end }}
