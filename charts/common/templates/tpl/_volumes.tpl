{{- define "common.tpl.volumes" -}}
  {{- $volumes := list -}}
  {{- $volumeNames := list -}}
  {{- $workloadType := include "common.helpers.names.workloadType" . -}}
  {{- range $volumeName, $persistence := .Values.persistence -}}
    {{- $volumeName = $persistence.name | default $volumeName -}}
    {{- if has $volumeName $volumeNames -}}
      {{- fail (printf "\"%s\" volume cannot be declared more than once!" $volumeName) -}}
    {{- end -}}
    {{- $volumeNames = append $volumeNames $volumeName -}}

    {{- /* 
      add name key into persistence object
    */ -}}
    {{- $persistence = merge (dict "name" $volumeName) $persistence -}}
    {{- $isPersistentVolumeClaimTemplate := and (include "common.helpers.persistence.isPersistentVolumeClaim" $persistence) (eq "StatefulSet" $workloadType) -}}
    {{- if and (($persistence).enabled | default true) (not $isPersistentVolumeClaimTemplate) -}}
      {{- $volume := include "common.tpl.volumes.volume" (dict "root" $ "persistence" $persistence) -}}
      {{- if $volume -}}
        {{- $volumes = append $volumes ($volume | fromYaml) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- if $volumes -}}
volumes:
{{ $volumes | toYaml }}
  {{- end -}}
{{- end }}

{{/*
Renders single volume definition for pod
Removes custom keys from spec definition
usage:
{{ include "common.tpl.volumes.volume" ( dict "root" $ "persistence" .Values.path.to.persistenceDefinition) }}
*/}}
{{- define "common.tpl.volumes.volume" -}}
  {{- $enabled := true -}}
  {{- if hasKey .persistence "enabled" -}}
    {{- $enabled = .persistence.enabled -}}
  {{- end -}}
  {{- if $enabled -}}
    {{- $fullName := include "common.helpers.names.fullname" .root  -}}
    {{- $workloadType := include "common.helpers.names.workloadType" .root -}}
    {{- $name := required ".Values.persistence items require \"name\" key!" .persistence.name -}}
    {{- $isPersistentVolumeClaim := include "common.helpers.persistence.isPersistentVolumeClaim" .persistence -}}
    {{- $isPersistentVolumeClaimTemplate := and $isPersistentVolumeClaim (eq "StatefulSet" $workloadType) -}}
    {{- $spec := (.persistence).spec | default (dict "emptyDir" dict) -}}
    {{- $useFromChart := or ($spec).useFromChart (not (hasKey $spec "useFromChart")) -}}
    {{- $spec = omit $spec "useFromChart" -}}
    {{- /*
        modify spec definition name
    */ -}}
    {{- if $spec.configMap -}}
      {{- $configMapName := include "common.helpers.names.configMapName" ( list .root $spec.configMap.name $useFromChart ) -}}
      {{- /*
        Run tpl against chart configmap name if useFromChart is false
      */ -}}
      {{- if not $useFromChart -}}
        {{- $configMapName = tpl $configMapName .root -}}
      {{- end -}}
      {{- $spec = merge (dict "configMap" (dict "name" $configMapName ) ) $spec -}}
    {{- else if and $spec.secret -}}
      {{- $secretName := include "common.helpers.names.secretName" ( list .root $spec.secret.name $useFromChart ) -}}
      {{- /*
        Run tpl against chart secret name if useFromChart is false
      */ -}}
      {{- if not $useFromChart -}}
        {{- $secretName = tpl $secretName .root -}}
      {{- end -}}
      {{- $spec = merge $spec (dict "secret" (dict "secretName" $secretName ) ) $spec -}}
    {{- else if and (not $isPersistentVolumeClaimTemplate) $isPersistentVolumeClaim -}}
      {{- $pvcName := include "common.helpers.names.persistentVolumeClaimName" ( list .root $name $useFromChart ) -}}
      {{- $spec = (dict "persistentVolumeClaim" (dict "claimName" $pvcName) ) -}}
    {{- end -}}

    {{- /*
        Check if is volumeClaimTemplate (only for statefulsets), those don't need to be declared into pod volumes, only as volumeMount
    */ -}}
    {{- if not $isPersistentVolumeClaimTemplate }}
name: {{ $name }}
{{ $spec | toYaml }}
    {{- end -}}
  {{- end -}}
{{- end }}