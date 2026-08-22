{{- define "orderservice.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "orderservice.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- include "orderservice.name" . }}
{{- end }}
{{- end }}

{{- define "orderservice.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | quote }}
app.kubernetes.io/name: {{ include "orderservice.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: "cppboostexample"
{{- end }}

{{- define "orderservice.selectorLabels" -}}
app.kubernetes.io/name: {{ include "orderservice.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}