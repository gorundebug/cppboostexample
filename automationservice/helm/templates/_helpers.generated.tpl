{{- define "automationservice.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "automationservice.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- include "automationservice.name" . }}
{{- end }}
{{- end }}

{{- define "automationservice.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | quote }}
app.kubernetes.io/name: {{ include "automationservice.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: "cppboostexample"
{{- end }}

{{- define "automationservice.selectorLabels" -}}
app.kubernetes.io/name: {{ include "automationservice.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}