{{ define "grafana.logsUrl" -}}
  {{- $args := .arg0 -}}
  {{- $datasourceUid := "PC27693B959EA3435" -}}
  {{- $datasourceType := "victoriametrics-logs-datasource" -}}
  {{- $to := .arg0 -}}
  {{- $from := .arg1 -}}
  {{- $expr := .arg2 -}}
  {{- $labels := .arg3 -}}
  {{- $orgId := 1 -}}
  {{- if $labels.explore_expression -}}
    {{- $expr = $labels.explore_expression | jsonEscape -}}
  {{- end -}}
  {{- /* datasource uid, datasource type, datasource uid, expression, from, to */ -}}
  {{- $panes := (printf `{"0":{"datasource":"%s","queries":[{"refId":"Alert","datasource":{"type":"%s","uid":"%s"},"editorMode":"code","expr":%s,"queryType":"instant"}],"range":{"from":"%d","to":"%d"}}}` $datasourceUid $datasourceType $datasourceUid $expr $from $to) -}}
  {{- printf "explore?schemaVersion=1&orgId=%d&panes=%s" $orgId ($panes | queryEscape) -}}
{{- end -}}

{{ define "grafana.metricsUrl" -}}
  {{- $args := .arg0 -}}
  {{- $datasourceUid := "PB03EEC818B40D27F" -}}
  {{- $datasourceType := "prometheus" -}}
  {{- $to := .arg0 -}}
  {{- $from := .arg1 -}}
  {{- $expr := .arg2 -}}
  {{- $labels := .arg3 -}}
  {{- $orgId := 1 -}}
  {{- if $labels.explore_expression -}}
    {{- $expr = $labels.explore_expression | jsonEscape -}}
  {{- end -}}
  {{- /* datasource uid, datasource type, datasource uid, expression, from, to */ -}}
  {{- $panes := (printf `{"0":{"datasource":"%s","queries":[{"refId":"Alert","datasource":{"type":"%s","uid":"%s"},"editorMode":"code","expr":%s,"range":true,"instant":true,"legendFormat":"__auto"}],"range":{"from":"%d","to":"%d"}}}` $datasourceUid $datasourceType $datasourceUid $expr $from $to) -}}
  {{- printf "explore?schemaVersion=1&orgId=%d&panes=%s" $orgId ($panes | queryEscape) -}}
{{- end -}}
