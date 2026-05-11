{{/*
Standard Helm name helpers.  Naming convention:
  fullname     = <release>-<chart>  (or fullnameOverride)
  service      = <fullname>-postgres
  headless svc = <fullname>-postgres-hl
*/}}

{{- define "telemetry-db.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "telemetry-db.fullname" -}}
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

{{- define "telemetry-db.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "telemetry-db.labels" -}}
helm.sh/chart: {{ include "telemetry-db.chart" . }}
{{ include "telemetry-db.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "telemetry-db.selectorLabels" -}}
app.kubernetes.io/name: {{ include "telemetry-db.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "telemetry-db.postgresLabels" -}}
{{ include "telemetry-db.selectorLabels" . }}
app.kubernetes.io/component: postgresql
{{- end }}

{{- define "telemetry-db.postgresServiceName" -}}
{{ include "telemetry-db.fullname" . }}-postgres
{{- end }}

{{- define "telemetry-db.postgresHeadlessServiceName" -}}
{{ include "telemetry-db.fullname" . }}-postgres-hl
{{- end }}

{{- define "telemetry-db.databaseUrl" -}}
{{- printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" .Values.postgresql.auth.username .Values.postgresql.auth.password (include "telemetry-db.postgresServiceName" .) .Values.postgresql.auth.database }}
{{- end }}
