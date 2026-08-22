{{- define "inventoryservice.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "inventoryservice.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- include "inventoryservice.name" . }}
{{- end }}
{{- end }}

{{- define "inventoryservice.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | quote }}
app.kubernetes.io/name: {{ include "inventoryservice.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: "cppboostexample"
{{- end }}

{{- define "inventoryservice.selectorLabels" -}}
app.kubernetes.io/name: {{ include "inventoryservice.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}