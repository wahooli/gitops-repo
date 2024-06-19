{{- define "netbootxyz.configMapName" -}}
{{- include "common.helpers.names.fullname" . -}}-initscript
{{- end }}

{{- define "netbootxyz.assetDownloaderScriptVolume" -}}
env:
  ASSETS_DIR: /assets
  ASSETS_CHOWN_USER: nbxyz
  ASSETS_CHOWN_GROUP: nbxyz
persistence:
  initcontainer-assets-dl:
    enabled: true
    mount:
    - path: /download-assets.sh
      subPath: download-assets.sh
    spec:
      configMap:
        name: {{ include "netbootxyz.configMapName" . }}
        defaultMode: 0777
{{- end }}

{{- define "netbootxyz.assetDownloaderScriptVolumeWithoutMount" -}}
persistence:
  initcontainer-assets-dl:
    enabled: true
    mount: []
    spec:
      configMap:
        name: {{ include "netbootxyz.configMapName" . }}
        defaultMode: 0777
{{- end }}

{{- define "netbootxyz.assetDownloaderInitContainer" -}}
podAnnotations:
  "checksum/assets": {{ .Values.netbootxyz.assets | toYaml | sha256sum }}
initContainers:
  download-assets:
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
    imagePullPolicy: {{ .Values.image.pullPolicy }}
    command:
    - /download-assets.sh
    {{- include "common.tpl.env" . | nindent 4 -}}
    {{- include "common.tpl.env.envFrom" . | nindent 4 -}}
    {{- include "common.tpl.volumeMounts" . | nindent 4 -}}
{{- end }}