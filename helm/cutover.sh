#!/usr/bin/env bash
# Replace the hand-written Ignition 8.1 Deployment with the official IA Helm chart (Ignition 8.3).
# Prereqs: `microk8s enable hostpath-storage` run on a node, and a .gwbk backup in ../backups.
set -euo pipefail

NS=ignition
CHART_VERSION=0.2.5
cd "$(dirname "$0")"

kubectl get storageclass microk8s-hostpath >/dev/null

# Admin password Secret, copied from the old Deployment so it never lands in git
if ! kubectl -n "$NS" get secret ignition-gateway-admin >/dev/null 2>&1; then
  PW=$(kubectl -n "$NS" get deploy ignition \
    -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="GATEWAY_ADMIN_PASSWORD")].value}')
  kubectl -n "$NS" create secret generic ignition-gateway-admin \
    --from-literal=gateway-admin-password="$PW"
  unset PW
fi

# The chart's Service is also named "ignition" and takes the same MetalLB IP
kubectl -n "$NS" delete deployment ignition --ignore-not-found
kubectl -n "$NS" delete service ignition --ignore-not-found
kubectl -n "$NS" delete pod debug --ignore-not-found --force --grace-period=0

helm repo add inductiveautomation https://charts.ia.io >/dev/null 2>&1 || true
helm repo update inductiveautomation >/dev/null
helm upgrade --install ignition inductiveautomation/ignition \
  --version "$CHART_VERSION" -n "$NS" -f values.yaml

kubectl -n "$NS" rollout status statefulset/ignition-gateway --timeout=10m
kubectl -n "$NS" get svc ignition
