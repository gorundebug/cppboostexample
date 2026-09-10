#!/bin/sh
set -eu

namespace="${DEFAULT_NAMESPACE:-default}"
address="${TEMPORAL_ADDRESS:-temporal:7233}"
max_attempts="${TEMPORAL_HEALTH_CHECK_MAX_ATTEMPTS:-30}"
sleep_seconds="${TEMPORAL_HEALTH_CHECK_SLEEP_SECONDS:-2}"
attempt=1

until temporal operator cluster health --address "${address}" >/dev/null 2>&1; do
  if [ "${attempt}" -ge "${max_attempts}" ]; then
    echo "Temporal is not healthy after ${max_attempts} attempts" >&2
    exit 1
  fi
  attempt=$((attempt + 1))
  sleep "${sleep_seconds}"
done

if temporal operator namespace describe -n "${namespace}" \
  --address "${address}" >/dev/null 2>&1; then
  echo "Temporal namespace ${namespace} already exists"
else
  temporal operator namespace create -n "${namespace}" \
    --address "${address}"
fi

# DescribeNamespace may observe persistence before frontend namespace caches
# accept workflow and schedule requests. Probe a namespace-scoped frontend API
# so dependent services only start after the namespace is actually usable.
attempt=1
until temporal workflow list -n "${namespace}" --limit 1 --output none \
  --command-timeout 5s --address "${address}" >/dev/null 2>&1; do
  if [ "${attempt}" -ge "${max_attempts}" ]; then
    echo "Temporal namespace ${namespace} is not usable after ${max_attempts} attempts" >&2
    exit 1
  fi
  attempt=$((attempt + 1))
  sleep "${sleep_seconds}"
done

echo "Temporal namespace ${namespace} is ready"