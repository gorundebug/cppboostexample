#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

COMPOSE=(docker compose -f docker-compose.kubernetes.yml)
NAMESPACE="${KUBERNETES_NAMESPACE:-cppboostexample}"
IMAGE_TAG="${KUBERNETES_IMAGE_TAG:-local}"
REGISTRY_PORT="${KUBERNETES_REGISTRY_PORT:-5001}"
HOST_REGISTRY="${KUBERNETES_REGISTRY_HOST:-localhost:${REGISTRY_PORT}}"
CLUSTER_REGISTRY="${KUBERNETES_CLUSTER_REGISTRY:-registry:5000}"
TIMEOUT="${KUBERNETES_TIMEOUT:-10m}"
KAFKA_SASL_ENABLED="${KUBERNETES_KAFKA_SASL_ENABLED:-false}"
KAFKA_SASL_MECHANISM="${KUBERNETES_KAFKA_SASL_MECHANISM:-SCRAM-SHA-512}"
KAFKA_SUPERUSERS_SECRET="${KUBERNETES_KAFKA_SUPERUSERS_SECRET:-redpanda-superusers}"
KAFKA_SERVICE_SECRET="${KUBERNETES_KAFKA_SERVICE_SECRET:-servicegen-kafka}"
HELM_CACHE_VOLUME="${KUBERNETES_HELM_CACHE_VOLUME:-servicegen-kubernetes-helm-cache}"
HELM_CONFIG_VOLUME="${KUBERNETES_HELM_CONFIG_VOLUME:-servicegen-kubernetes-helm-config}"
DOCKER_ARCH="${KUBERNETES_IMAGE_CACHE_ARCH:-$(docker info --format '{{.Architecture}}')}"
IMAGE_CACHE_VOLUME="${KUBERNETES_IMAGE_CACHE_VOLUME:-servicegen-kubernetes-image-cache-v1-${DOCKER_ARCH}}"
export KUBERNETES_IMAGE_CACHE_VOLUME="${IMAGE_CACHE_VOLUME}"
GRAFANA_ADMIN_PASSWORD="${KUBERNETES_GRAFANA_ADMIN_PASSWORD:-admin}"
TEMPORAL_POSTGRES_PASSWORD="${KUBERNETES_TEMPORAL_POSTGRES_PASSWORD:-temporal}"

progress() { printf '==> [kubernetes] %s\n' "$*"; }

json_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/\\r}"
  value="${value//$'\t'/\\t}"
  printf '%s' "${value}"
}

wait_for_cluster() {
  progress "waiting for k3s readiness"
  for _ in $(seq 1 120); do
    if "${COMPOSE[@]}" exec -T kubernetes kubectl get --raw=/readyz >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  "${COMPOSE[@]}" logs --no-color --tail 200 kubernetes >&2 || true
  echo "k3s did not become ready within 120 seconds" >&2
  return 1
}

ensure_tool_caches() {
  docker volume inspect "${IMAGE_CACHE_VOLUME}" >/dev/null 2>&1 ||
    docker volume create "${IMAGE_CACHE_VOLUME}" >/dev/null
  docker volume inspect "${HELM_CACHE_VOLUME}" >/dev/null 2>&1 ||
    docker volume create "${HELM_CACHE_VOLUME}" >/dev/null
  docker volume inspect "${HELM_CONFIG_VOLUME}" >/dev/null 2>&1 ||
    docker volume create "${HELM_CONFIG_VOLUME}" >/dev/null
}

helm() {
  "${COMPOSE[@]}" --profile tools run --rm --no-deps helm "$@"
}

ensure_helm_repo() {
  local name="$1"
  local url="$2"
  if helm repo list 2>/dev/null | awk -v name="${name}" -v url="${url}" \
    'NR > 1 && $1 == name && $2 == url { found = 1 } END { exit !found }'; then
    progress "reusing cached Helm repository index for ${name}"
    return 0
  fi
  helm repo add "${name}" "${url}" --force-update
}

kubectl() {
  "${COMPOSE[@]}" exec -T kubernetes kubectl "$@"
}

ensure_namespace() {
  kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml |
    kubectl apply -f - >/dev/null
}

configure_kafka_secrets() {
  set --
  if [[ "${KAFKA_SASL_ENABLED}" == "true" ]]; then
    : "${KUBERNETES_KAFKA_USERNAME:?set KUBERNETES_KAFKA_USERNAME when Kubernetes Kafka SASL is enabled}"
    : "${KUBERNETES_KAFKA_PASSWORD:?set KUBERNETES_KAFKA_PASSWORD when Kubernetes Kafka SASL is enabled}"
    case "${KAFKA_SASL_MECHANISM}" in
      SCRAM-SHA-256|SCRAM-SHA-512) ;;
      *)
        echo "KUBERNETES_KAFKA_SASL_MECHANISM must be SCRAM-SHA-256 or SCRAM-SHA-512" >&2
        return 2
        ;;
    esac

    progress "creating idempotent Kubernetes Secrets for Kafka SASL"
    kubectl --namespace "${NAMESPACE}" create secret generic "${KAFKA_SUPERUSERS_SECRET}" \
      --from-literal="superusers.txt=${KUBERNETES_KAFKA_USERNAME}:${KUBERNETES_KAFKA_PASSWORD}:${KAFKA_SASL_MECHANISM}" \
      --dry-run=client -o yaml | kubectl apply -f - >/dev/null
    set -- "$@" \
      --from-literal="ORDER_EVENTS_USERNAME=${KUBERNETES_KAFKA_USERNAME}" \
      --from-literal="ORDER_EVENTS_PASSWORD=${KUBERNETES_KAFKA_PASSWORD}" \
      --from-literal="ORDER_EVENTS_SECURITY_PROTOCOL=SASL_PLAINTEXT" \
      --from-literal="ORDER_EVENTS_SASL_MECHANISM=${KAFKA_SASL_MECHANISM}"
  fi
  if [[ "$#" -eq 0 ]]; then
    return 0
  fi
  progress "creating idempotent service configuration Secret"
  kubectl --namespace "${NAMESPACE}" create secret generic "${KAFKA_SERVICE_SECRET}" \
    "$@" \
    --dry-run=client -o yaml | kubectl apply -f - >/dev/null
}

infra_up() {
  ensure_tool_caches
  progress "starting project registry and k3s"
  "${COMPOSE[@]}" up -d registry kubernetes
  wait_for_cluster
}

build_images() {
  progress "building existing minimal runtime images"
  make docker-build RUNTIME_IMAGE=1
  progress "publishing analyticsservice image"
  docker tag "cppboostexample-analyticsservice:latest" \
    "${HOST_REGISTRY}/cppboostexample/analyticsservice:${IMAGE_TAG}"
  docker push \
    "${HOST_REGISTRY}/cppboostexample/analyticsservice:${IMAGE_TAG}"
  progress "publishing automationservice image"
  docker tag "automationservice:latest" \
    "${HOST_REGISTRY}/cppboostexample/automationservice:${IMAGE_TAG}"
  docker push \
    "${HOST_REGISTRY}/cppboostexample/automationservice:${IMAGE_TAG}"
  progress "publishing inventoryservice image"
  docker tag "cppboostexample-inventoryservice:latest" \
    "${HOST_REGISTRY}/cppboostexample/inventoryservice:${IMAGE_TAG}"
  docker push \
    "${HOST_REGISTRY}/cppboostexample/inventoryservice:${IMAGE_TAG}"
  progress "publishing orderservice image"
  docker tag "cppboostexample-orderservice:latest" \
    "${HOST_REGISTRY}/cppboostexample/orderservice:${IMAGE_TAG}"
  docker push \
    "${HOST_REGISTRY}/cppboostexample/orderservice:${IMAGE_TAG}"
}

configure_grafana_dashboards() {
  progress "provisioning generated service dashboards"
  kubectl --namespace "${NAMESPACE}" delete configmap \
    --selector=servicegen.dev/generated-dashboard=true \
    --ignore-not-found >/dev/null
  dashboard_index=0
  for dashboard in analyticsservice/grafana/dist/*.json; do
    [[ -f "${dashboard}" ]] || continue
    dashboard_index=$((dashboard_index + 1))
    configmap="analyticsservice-dashboard-${dashboard_index}"
    kubectl --namespace "${NAMESPACE}" create configmap "${configmap}" \
      --from-file="$(basename "${dashboard}")=/dev/stdin" \
      --dry-run=client -o yaml < "${dashboard}" | kubectl apply -f - >/dev/null
    kubectl --namespace "${NAMESPACE}" label configmap "${configmap}" \
      grafana_dashboard=1 servicegen.dev/generated-dashboard=true \
      --overwrite >/dev/null
    kubectl --namespace "${NAMESPACE}" annotate configmap "${configmap}" \
      grafana_folder=analyticsservice \
      --overwrite >/dev/null
  done
  dashboard_index=0
  for dashboard in automationservice/grafana/dist/*.json; do
    [[ -f "${dashboard}" ]] || continue
    dashboard_index=$((dashboard_index + 1))
    configmap="automationservice-dashboard-${dashboard_index}"
    kubectl --namespace "${NAMESPACE}" create configmap "${configmap}" \
      --from-file="$(basename "${dashboard}")=/dev/stdin" \
      --dry-run=client -o yaml < "${dashboard}" | kubectl apply -f - >/dev/null
    kubectl --namespace "${NAMESPACE}" label configmap "${configmap}" \
      grafana_dashboard=1 servicegen.dev/generated-dashboard=true \
      --overwrite >/dev/null
    kubectl --namespace "${NAMESPACE}" annotate configmap "${configmap}" \
      grafana_folder=automationservice \
      --overwrite >/dev/null
  done
  dashboard_index=0
  for dashboard in inventoryservice/grafana/dist/*.json; do
    [[ -f "${dashboard}" ]] || continue
    dashboard_index=$((dashboard_index + 1))
    configmap="inventoryservice-dashboard-${dashboard_index}"
    kubectl --namespace "${NAMESPACE}" create configmap "${configmap}" \
      --from-file="$(basename "${dashboard}")=/dev/stdin" \
      --dry-run=client -o yaml < "${dashboard}" | kubectl apply -f - >/dev/null
    kubectl --namespace "${NAMESPACE}" label configmap "${configmap}" \
      grafana_dashboard=1 servicegen.dev/generated-dashboard=true \
      --overwrite >/dev/null
    kubectl --namespace "${NAMESPACE}" annotate configmap "${configmap}" \
      grafana_folder=inventoryservice \
      --overwrite >/dev/null
  done
  dashboard_index=0
  for dashboard in orderservice/grafana/dist/*.json; do
    [[ -f "${dashboard}" ]] || continue
    dashboard_index=$((dashboard_index + 1))
    configmap="orderservice-dashboard-${dashboard_index}"
    kubectl --namespace "${NAMESPACE}" create configmap "${configmap}" \
      --from-file="$(basename "${dashboard}")=/dev/stdin" \
      --dry-run=client -o yaml < "${dashboard}" | kubectl apply -f - >/dev/null
    kubectl --namespace "${NAMESPACE}" label configmap "${configmap}" \
      grafana_dashboard=1 servicegen.dev/generated-dashboard=true \
      --overwrite >/dev/null
    kubectl --namespace "${NAMESPACE}" annotate configmap "${configmap}" \
      grafana_folder=orderservice \
      --overwrite >/dev/null
  done
}

deploy_observability() {
  progress "generating Grafana dashboards"
  make grafana-dashboards
  progress "installing pinned Prometheus and Grafana stack"
  ensure_helm_repo prometheus-community "${SERVICEGEN_HELM_PROMETHEUS_URL:-https://prometheus-community.github.io/helm-charts}"
  ensure_helm_repo open-telemetry "${SERVICEGEN_HELM_OPENTELEMETRY_URL:-https://open-telemetry.github.io/opentelemetry-helm-charts}"
  ensure_helm_repo jaegertracing "${SERVICEGEN_HELM_JAEGER_URL:-https://jaegertracing.github.io/helm-charts}"
  ensure_helm_repo grafana "${SERVICEGEN_HELM_GRAFANA_URL:-https://grafana.github.io/helm-charts}"

  helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
    --version 88.5.3 \
    --namespace "${NAMESPACE}" --create-namespace \
    --values kubernetes/monitoring-values.generated.yaml \
    --set-string grafana.adminPassword="${GRAFANA_ADMIN_PASSWORD}" \
    --wait --timeout "${TIMEOUT}"
  helm upgrade --install loki grafana/loki \
    --version 7.3.0 \
    --namespace "${NAMESPACE}" --create-namespace \
    --values kubernetes/loki-values.generated.yaml \
    --wait --timeout "${TIMEOUT}"
  helm upgrade --install jaeger jaegertracing/jaeger \
    --version 4.12.0 \
    --namespace "${NAMESPACE}" --create-namespace \
    --values kubernetes/jaeger-values.generated.yaml \
    --wait --timeout "${TIMEOUT}"
  helm upgrade --install otel-collector open-telemetry/opentelemetry-collector \
    --version 0.170.0 \
    --namespace "${NAMESPACE}" --create-namespace \
    --values kubernetes/otel-collector-values.generated.yaml \
    --wait --timeout "${TIMEOUT}"
  configure_grafana_dashboards
}

deploy_infrastructure() {
  ensure_namespace
  deploy_observability
  configure_kafka_secrets
  progress "installing pinned Redpanda chart"
  ensure_helm_repo redpanda "${SERVICEGEN_HELM_REDPANDA_URL:-https://charts.redpanda.com}"
  set --
  if [[ "${KAFKA_SASL_ENABLED}" == "true" ]]; then
    set -- \
      --set auth.sasl.enabled=true \
      --set-string "auth.sasl.secretRef=${KAFKA_SUPERUSERS_SECRET}" \
      --set auth.sasl.users=null
  fi
  helm upgrade --install redpanda redpanda/redpanda \
    --version 26.2.1 \
    --namespace "${NAMESPACE}" --create-namespace \
    --values kubernetes/redpanda-values.generated.yaml \
    "$@" \
    --wait --timeout "${TIMEOUT}"
  progress "creating the local Temporal persistence Secret"
  kubectl --namespace "${NAMESPACE}" create secret generic \
    temporal-postgresql \
    --from-literal=password="${TEMPORAL_POSTGRES_PASSWORD}" \
    --dry-run=client -o yaml | kubectl apply -f - >/dev/null
  progress "starting pinned PostgreSQL for Temporal"
  kubectl --namespace "${NAMESPACE}" apply -f - \
    < kubernetes/temporal-postgresql.generated.yaml >/dev/null
  kubectl --namespace "${NAMESPACE}" rollout status \
    statefulset/temporal-postgresql --timeout="${TIMEOUT}"

  progress "installing pinned Temporal chart"
  ensure_helm_repo temporal \
    "${SERVICEGEN_HELM_TEMPORAL_URL:-https://go.temporal.io/helm-charts}"
  helm upgrade --install temporal temporal/temporal \
    --version 1.6.0 \
    --namespace "${NAMESPACE}" --create-namespace \
    --values kubernetes/temporal-values.generated.yaml \
    --wait --timeout "${TIMEOUT}"
}

deploy_services() {
  set --
  if [[ "${KAFKA_SASL_ENABLED}" == "true" ]]; then
    set -- --set-string "secretEnvFrom[0]=${KAFKA_SERVICE_SECRET}"
  fi
  progress "installing service Helm releases"
  set -- "$@" \
    --set-string env.ANALYTICS_SERVICE_ENVIRONMENT=staging \
    --set-string env.OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317 \
    --set-string env.OTEL_EXPORTER_OTLP_INSECURE=true \
    --set-string env.OTEL_METRIC_EXPORT_INTERVAL=5000
  set -- "$@" --set metrics.serviceMonitor.enabled=true
  helm upgrade --install analyticsservice \
    analyticsservice/helm \
    --namespace "${NAMESPACE}" --create-namespace \
    --values analyticsservice/helm/values.generated.yaml \
    --values analyticsservice/helm/values.yaml \
    --set-string image.repository="${CLUSTER_REGISTRY}/cppboostexample/analyticsservice" \
    --set-string image.tag="${IMAGE_TAG}" \
    "$@"
  set --
  if [[ "${KAFKA_SASL_ENABLED}" == "true" ]]; then
    set -- --set-string "secretEnvFrom[0]=${KAFKA_SERVICE_SECRET}"
  fi
  set -- "$@" \
    --set-string env.AUTOMATION_SERVICE_ENVIRONMENT=staging \
    --set-string env.OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317 \
    --set-string env.OTEL_EXPORTER_OTLP_INSECURE=true \
    --set-string env.OTEL_METRIC_EXPORT_INTERVAL=5000
  helm upgrade --install automationservice \
    automationservice/helm \
    --namespace "${NAMESPACE}" --create-namespace \
    --values automationservice/helm/values.generated.yaml \
    --values automationservice/helm/values.yaml \
    --set-string image.repository="${CLUSTER_REGISTRY}/cppboostexample/automationservice" \
    --set-string image.tag="${IMAGE_TAG}" \
    "$@"
  set --
  if [[ "${KAFKA_SASL_ENABLED}" == "true" ]]; then
    set -- --set-string "secretEnvFrom[0]=${KAFKA_SERVICE_SECRET}"
  fi
  set -- "$@" \
    --set-string env.INVENTORY_SERVICE_ENVIRONMENT=staging \
    --set-string env.OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317 \
    --set-string env.OTEL_EXPORTER_OTLP_INSECURE=true \
    --set-string env.OTEL_METRIC_EXPORT_INTERVAL=5000
  set -- "$@" --set metrics.serviceMonitor.enabled=true
  helm upgrade --install inventoryservice \
    inventoryservice/helm \
    --namespace "${NAMESPACE}" --create-namespace \
    --values inventoryservice/helm/values.generated.yaml \
    --values inventoryservice/helm/values.yaml \
    --set-string image.repository="${CLUSTER_REGISTRY}/cppboostexample/inventoryservice" \
    --set-string image.tag="${IMAGE_TAG}" \
    "$@"
  set --
  if [[ "${KAFKA_SASL_ENABLED}" == "true" ]]; then
    set -- --set-string "secretEnvFrom[0]=${KAFKA_SERVICE_SECRET}"
  fi
  set -- "$@" \
    --set-string env.ORDER_SERVICE_ENVIRONMENT=staging \
    --set-string env.OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317 \
    --set-string env.OTEL_EXPORTER_OTLP_INSECURE=true \
    --set-string env.OTEL_METRIC_EXPORT_INTERVAL=5000
  set -- "$@" --set metrics.serviceMonitor.enabled=true
  helm upgrade --install orderservice \
    orderservice/helm \
    --namespace "${NAMESPACE}" --create-namespace \
    --values orderservice/helm/values.generated.yaml \
    --values orderservice/helm/values.yaml \
    --set-string image.repository="${CLUSTER_REGISTRY}/cppboostexample/orderservice" \
    --set-string image.tag="${IMAGE_TAG}" \
    "$@"
  set --
  if [[ "${KAFKA_SASL_ENABLED}" == "true" ]]; then
    set -- --set-string "secretEnvFrom[0]=${KAFKA_SERVICE_SECRET}"
  fi
}

verify() {
  progress "waiting for service rollouts"
  kubectl --namespace "${NAMESPACE}" rollout status \
    deployment/analyticsservice --timeout="${TIMEOUT}"
  kubectl --namespace "${NAMESPACE}" rollout status \
    deployment/automationservice --timeout="${TIMEOUT}"
  kubectl --namespace "${NAMESPACE}" rollout status \
    deployment/inventoryservice --timeout="${TIMEOUT}"
  kubectl --namespace "${NAMESPACE}" rollout status \
    deployment/orderservice --timeout="${TIMEOUT}"
  progress "checking service health through the Kubernetes API proxy"
  kubectl get --raw \
    "/api/v1/namespaces/${NAMESPACE}/services/http:analyticsservice:9093/proxy/health/ready" \
    >/dev/null
  printf '  PASS  analyticsservice /health/ready\n'
  kubectl get --raw \
    "/api/v1/namespaces/${NAMESPACE}/services/http:automationservice:9094/proxy/health/ready" \
    >/dev/null
  printf '  PASS  automationservice /health/ready\n'
  kubectl get --raw \
    "/api/v1/namespaces/${NAMESPACE}/services/http:inventoryservice:9092/proxy/health/ready" \
    >/dev/null
  printf '  PASS  inventoryservice /health/ready\n'
  kubectl get --raw \
    "/api/v1/namespaces/${NAMESPACE}/services/http:orderservice:9091/proxy/health/ready" \
    >/dev/null
  printf '  PASS  orderservice /health/ready\n'
  progress "checking Prometheus, Grafana, Jaeger, Loki and OTel Collector"
  kubectl get --raw \
    "/api/v1/namespaces/${NAMESPACE}/services/http:monitoring-kube-prometheus-prometheus:9090/proxy/-/ready" \
    >/dev/null
  printf '  PASS  prometheus ready\n'
  kubectl get --raw \
    "/api/v1/namespaces/${NAMESPACE}/services/http:monitoring-grafana:80/proxy/api/health" \
    >/dev/null
  printf '  PASS  grafana ready\n'
  kubectl get --raw \
    "/api/v1/namespaces/${NAMESPACE}/services/http:jaeger:16686/proxy/api/services" \
    >/dev/null
  printf '  PASS  jaeger query API\n'
  kubectl get --raw \
    "/api/v1/namespaces/${NAMESPACE}/services/http:loki-gateway:80/proxy/loki/api/v1/status/buildinfo" \
    >/dev/null
  printf '  PASS  loki ready\n'
  kubectl --namespace "${NAMESPACE}" rollout status deployment/otel-collector --timeout="${TIMEOUT}"
  printf '  PASS  otel collector ready\n'
  progress "checking Temporal server, namespace and Web UI"
  for component in frontend history matching worker; do
    kubectl --namespace "${NAMESPACE}" rollout status \
      "deployment/temporal-${component}" --timeout="${TIMEOUT}"
  done
  kubectl --namespace "${NAMESPACE}" exec deployment/temporal-admintools -- \
    temporal operator cluster health --address temporal-frontend:7233 >/dev/null
  kubectl --namespace "${NAMESPACE}" exec deployment/temporal-admintools -- \
    temporal operator namespace describe -n default \
      --address temporal-frontend:7233 >/dev/null
  kubectl get --raw \
    "/api/v1/namespaces/${NAMESPACE}/services/http:temporal-web:8080/proxy/" \
    >/dev/null
  printf '  PASS  temporal cluster, default namespace and Web UI\n'
  dashboard_count="$(kubectl --namespace "${NAMESPACE}" get configmap \
    --selector=servicegen.dev/generated-dashboard=true \
    -o go-template='{{len .items}}')"
  expected_dashboard_count=0
  for dashboard in analyticsservice/grafana/dist/*.json; do
    [[ -f "${dashboard}" ]] || continue
    expected_dashboard_count=$((expected_dashboard_count + 1))
  done
  for dashboard in automationservice/grafana/dist/*.json; do
    [[ -f "${dashboard}" ]] || continue
    expected_dashboard_count=$((expected_dashboard_count + 1))
  done
  for dashboard in inventoryservice/grafana/dist/*.json; do
    [[ -f "${dashboard}" ]] || continue
    expected_dashboard_count=$((expected_dashboard_count + 1))
  done
  for dashboard in orderservice/grafana/dist/*.json; do
    [[ -f "${dashboard}" ]] || continue
    expected_dashboard_count=$((expected_dashboard_count + 1))
  done
  if [[ "${dashboard_count}" -ne "${expected_dashboard_count}" ]]; then
    echo "expected ${expected_dashboard_count} generated Grafana dashboards, found ${dashboard_count}" >&2
    return 1
  fi
  printf '  PASS  generated Grafana dashboards (%s ConfigMaps)\n' "${dashboard_count}"
}

case "${1:-up}" in
  infra-up)
    infra_up
    ;;
  build)
    infra_up
    build_images
    ;;
  deploy)
    infra_up
    deploy_infrastructure
    deploy_services
    ;;
  up)
    infra_up
    build_images
    deploy_infrastructure
    deploy_services
    verify
    ;;
  test)
    wait_for_cluster
    verify
    ;;
  status)
    wait_for_cluster
    kubectl get nodes -o wide
    kubectl --namespace "${NAMESPACE}" get pods,services
    helm list --namespace "${NAMESPACE}"
    ;;
  down)
    progress "stopping local Kubernetes infrastructure"
    "${COMPOSE[@]}" down --remove-orphans
    ;;
  clean)
    progress "removing local Kubernetes infrastructure and volumes"
    "${COMPOSE[@]}" down --volumes --remove-orphans
    ;;
  *)
    echo "usage: $0 {up|infra-up|build|deploy|test|status|down|clean}" >&2
    exit 2
    ;;
esac