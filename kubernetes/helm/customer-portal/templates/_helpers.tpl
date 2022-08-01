{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "customer-portal.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "customer-portal.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "customer-portal.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generar el nombre completo de la url para el ingress a partir de los datos del proyecto
*/}}
{{- define "datosProyecto.url"}}
  {{- if .Values.datosProyecto.idMergeRequest -}}
    {{- printf "%s-%s-%s-%s-%s" .Values.datosProyecto.cliente .Values.datosProyecto.proyecto .Values.datosProyecto.aplicacion .Values.datosProyecto.idMergeRequest .Values.datosProyecto.entorno | replace "--" "-" -}}
  {{- else -}}
    {{- printf "%s-%s-%s-%s" .Values.datosProyecto.cliente .Values.datosProyecto.proyecto .Values.datosProyecto.aplicacion .Values.datosProyecto.entorno | replace "--" "-" -}}
  {{- end -}}
{{- end -}}

{{/*
Generar el nombre completo de la url para el ingress a partir de los datos del proyecto
*/}}
{{- define "datosProyecto.nombre"}}
{{- printf "%s-%s-%s-%s" .Values.datosProyecto.cliente .Values.datosProyecto.proyecto .Values.datosProyecto.aplicacion .Values.datosProyecto.entorno -}}
{{- end -}}

{{- define "include_branch_name" -}}
  {{- if .Values.datosProyecto.idMergeRequest -}}
    {{- printf "-%s" .Values.datosProyecto.idMergeRequest -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}

{{- define "whitelist" -}}
  {{- if .Values.datosProyecto.whitelist.enabled -}}
    {{- join "," .Values.datosProyecto.whitelist.listIp }}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}