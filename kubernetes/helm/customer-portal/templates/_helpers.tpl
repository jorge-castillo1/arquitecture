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

{{- define "namespace_domain" -}}
{{- printf ".mongodb%s-headless.%s.svc.cluster.local" (include "include_branch_name" $) .Release.Namespace -}}
{{- end -}}

{{- define "include_branch_name" -}}
  {{- if .Values.datosProyecto.idMergeRequest -}}
    {{- printf "-%s" .Values.datosProyecto.idMergeRequest -}}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}



{{- define "mongo_name_constructor" -}}
  {{- if .Values.datosProyecto.idMergeRequest -}}
    {{- printf "%s-%s" $.Values.mongodb.fullnameOverride .Values.datosProyecto.idMergeRequest -}}
  {{- else -}}
    {{- printf "%s" $.Values.mongodb.fullnameOverride -}}
  {{- end -}}  
{{- end -}}

{{- define "mongodb_replicaset_url" -}}
    {{- printf "mongodb://" -}}
{{- if .Values.mongodb.usePassword }}
  {{- printf "%s:%s@" .Values.mongodb.dbuser .Values.mongodb.dbpassword }}
{{- end -}}
{{- if not .Values.mongodb.replicaSet.enabled -}}
  {{- if .Values.datosProyecto.idMergeRequest -}}
    {{- printf "mongodb-%s/%s" .Values.datosProyecto.idMergeRequest $.Values.mongodb.database -}}
  {{- else -}}
    {{- printf "mongodb/%s?authSource=admin&readPreference=primary&directConnection=true&ssl=false" $.Values.mongodb.database -}}
  {{- end -}}
{{- else -}}
  {{- printf "%s-primary-0%s" (include "mongo_name_constructor" $) (include "namespace_domain" $) -}}
  {{- if gt ( sub ($.Values.mongodb.replicaSet.replicas.secondary|int) 1 ) 0 -}}
      {{- printf "," -}}
  {{- end -}}
  {{- range $mongocount, $e := until (.Values.mongodb.replicaSet.replicas.secondary|int) -}}
    {{- printf "%s-secondary-%d%s" (include "mongo_name_constructor" $) $mongocount (include "namespace_domain" $) -}}
    {{- if lt $mongocount  ( sub ($.Values.mongodb.replicaSet.replicas.secondary|int) 1 ) -}}
      {{- printf "," -}}
    {{- end -}}
  {{- end -}}
  {{- printf "/%s?replicaSet=%s?authSource=admin&readPreference=secondary&directConnection=true&ssl=false" $.Values.mongodb.database  $.Values.mongodb.replicaSet.name -}}
{{- end -}}
{{- end -}}

{{- define "mongodb_replicaset_host" -}}
{{- if not .Values.mongodb.replicaSet.enabled -}}
  {{- printf "mongodb%s" (include "include_branch_name" $) -}}
{{- else -}}
  {{- printf "%s-primary-0%s" (include "mongo_name_constructor" $) (include "namespace_domain" $) -}}
{{- end -}}
{{- end -}}

{{- define "mongodb.fullname" -}}
{{- if .Values.datosProyecto.idMergeRequest -}}
    {{- printf "%s-%s" $.Values.fullnameOverride $.Values.datosProyecto.idMergeRequest -}}
  {{- else -}}
    {{- printf "%s" $.Values.fullnameOverride -}}
  {{- end -}}
{{- end -}}

{{- define "mongodb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "whitelist" -}}
  {{- if .Values.datosProyecto.whitelist.enabled -}}
    {{- join "," .Values.datosProyecto.whitelist.listIp }}
  {{- else -}}
    {{- printf "" -}}
  {{- end -}}
{{- end -}}