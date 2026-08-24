# Local Kubernetes

The project owns one local k3s cluster and OCI registry. Each service owns its
independently installable Helm chart under `<service>/helm`. The local cluster
also installs pinned Redpanda, Prometheus, Grafana, OpenTelemetry Collector,
Jaeger and Loki releases so metrics, traces, logs and generated dashboards can
be verified together.

```bash
make kubernetes-up       # build runtime images, start k3s, deploy and verify
make kubernetes-status   # show nodes, pods, services and Helm releases
make kubernetes-test     # verify probes, metrics and the order -> Kafka -> analytics flow
make kubernetes-down     # stop the local cluster and preserve its volumes
make kubernetes-clean    # remove the cluster, registry and all local volumes
```

Use `<service>/helm/values.yaml` for project-specific overrides. Generated
defaults stay in `values.generated.yaml` and are replaced on regeneration.
Production clusters use the same service charts with their own registry,
resources, security policy, ingress, secrets and Kafka configuration.

The service charts remain observability-vendor-neutral. Local OTLP endpoints,
backends and dashboard provisioning are applied only by the project-level
`kubernetes.generated.sh` orchestration.

## Inspecting the local observability stack

The stack is reachable through explicit port forwards:

```bash
# Grafana (admin / KUBERNETES_GRAFANA_ADMIN_PASSWORD, default: admin)
docker compose -f docker-compose.kubernetes.yml exec kubernetes \
  kubectl -n cppboostexample port-forward service/monitoring-grafana 3000:80

# Prometheus
docker compose -f docker-compose.kubernetes.yml exec kubernetes \
  kubectl -n cppboostexample port-forward \
  service/monitoring-kube-prometheus-prometheus 9090:9090

# Jaeger
docker compose -f docker-compose.kubernetes.yml exec kubernetes \
  kubectl -n cppboostexample port-forward service/jaeger 16686:16686
```

Set `KUBERNETES_NAMESPACE` when using a namespace other than the generated
default. Loki uses a local persistent volume and Jaeger uses ephemeral memory;
production retention and storage remain cluster-operator responsibilities.

## Secrets and Kafka authentication

Non-secret runtime settings are rendered into a `ConfigMap`. Secret values are
never generated into chart values or committed files. Each service chart exposes
the vendor-neutral `secretEnvFrom` list, so production may use a Secret created
by Vault, External Secrets Operator, Sealed Secrets, a cloud provider or ordinary
`kubectl` without changing the chart.

The local cluster can exercise real Redpanda SASL/SCRAM authentication. The
script creates the broker and service Secrets idempotently from the process
environment and references the service Secret through `secretEnvFrom`:

```bash
KUBERNETES_KAFKA_SASL_ENABLED=true \
KUBERNETES_KAFKA_USERNAME=servicegen-local \
KUBERNETES_KAFKA_PASSWORD='replace-this-local-password' \
make kubernetes-up
```

`KUBERNETES_KAFKA_SASL_MECHANISM` defaults to `SCRAM-SHA-512`. Existing
production Secrets can be selected with `KUBERNETES_KAFKA_SUPERUSERS_SECRET`
and `KUBERNETES_KAFKA_SERVICE_SECRET`; secret ownership remains outside the
service chart.

The Compose cluster is local development infrastructure, not a production
Kubernetes distribution.

## Temporal

The graph contains a Temporal connector, so the local environment also starts
the pinned Temporal Server, matching Admin Tools, PostgreSQL persistence and Web
UI. Compose exposes the frontend on `localhost:${TEMPORAL_PORT:-7233}` and the UI
on `http://localhost:${TEMPORAL_UI_PORT:-8080}`.

The Kubernetes path installs the official pinned Temporal chart and a local
PostgreSQL StatefulSet. The database password is created as a Kubernetes Secret
from `KUBERNETES_TEMPORAL_POSTGRES_PASSWORD` (local default: `temporal`); it is
never rendered into a ConfigMap or generated values file. Generated service
configuration uses the cluster-internal `temporal-frontend:7233` address.

Observability keeps three metric owners separate. Temporal Server exports its
official server metrics; each supported SDK/Worker process exports official SDK
metrics on port `9464`; and ServiceLib exports application/graph metrics on the
service HTTP metrics handler. Prometheus scrapes all three sources in both
Compose and Kubernetes. ServiceLib does not remeasure Temporal queue, Workflow,
Activity, or retry latency; dashboards map the official Temporal series to the
corresponding `DurableCall` view and add only graph-level context.

Production deployments should replace the local PostgreSQL manifest and Secret
with operator-owned persistence and secret management while retaining the same
service chart and connector environment contract.