#!/usr/bin/env bash
set -euo pipefail

build_dir="${1:?build directory is required}"
sanitizer="${2:?sanitizer name is required}"
case "$sanitizer" in
  asan)
    export ASAN_OPTIONS="detect_leaks=1:halt_on_error=1"
    export UBSAN_OPTIONS="halt_on_error=1"
    ;;
  tsan)
    export TSAN_OPTIONS="halt_on_error=1"
    ;;
  *)
    echo "unsupported sanitizer: $sanitizer" >&2
    exit 2
    ;;
esac

inventory_pid=""
order_pid=""
cleanup() {
  if [[ -n "$order_pid" ]]; then
    kill -TERM "$order_pid" 2>/dev/null || true
    wait "$order_pid" 2>/dev/null || true
  fi
  if [[ -n "$inventory_pid" ]]; then
    kill -TERM "$inventory_pid" 2>/dev/null || true
    wait "$inventory_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT

SERVICELIB_NOOP_METRICS=1 \
  "./${build_dir}/inventoryservice/example_inventory_service" \
    --config inventoryservice/config/config.yaml \
    --values inventoryservice/config/overrides.yaml \
    --workers 2 &
inventory_pid="$!"

ORDER_PROCESSED_ENABLED=false \
INVENTORY_SERVICE_API_ADDRESS=dns:///127.0.0.1:9202 \
SERVICELIB_NOOP_METRICS=1 \
  "./${build_dir}/orderservice/example_order_service" \
    --config orderservice/config/config.yaml \
    --values orderservice/config/overrides.yaml \
    --workers 2 &
order_pid="$!"

ready=0
ready_deadline=$((SECONDS + 120))
while (( SECONDS < ready_deadline )); do
  if python3 -c 'import json, urllib.request; assert all(set(("nodes", "edges")) <= json.load(urllib.request.urlopen(f"http://127.0.0.1:{port}/status/data", timeout=2)).keys() for port in (9091, 9092))' \
      >/dev/null 2>&1; then
    ready=1
    break
  fi
  if ! kill -0 "$inventory_pid" 2>/dev/null || \
     ! kill -0 "$order_pid" 2>/dev/null; then
    echo "sanitized generated service exited before readiness" >&2
    exit 1
  fi
  sleep 0.1
done
if [[ "$ready" -ne 1 ]]; then
  echo "sanitized generated services did not become ready" >&2
  exit 1
fi

python3 - <<'PY'
import json
import urllib.request

def get(port):
    with urllib.request.urlopen(
        f"http://127.0.0.1:{port}/status/data", timeout=5
    ) as response:
        assert response.status == 200
        graph = json.load(response)
        assert isinstance(graph["nodes"], list)
        assert isinstance(graph["edges"], list)
        assert graph["nodes"]

def process(request_id, items):
    request = urllib.request.Request(
        "http://127.0.0.1:9091/v1/processorder",
        data=json.dumps({"customer_id": "sanitizer", "items": items}).encode(),
        headers={"Content-Type": "application/json", "X-Request-ID": request_id},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=10) as response:
        assert response.status == 200
        return json.loads(response.read())

get(9091)
get(9092)
confirmed = process("sanitizer-confirmed", [{
    "item_id": "item-1", "sku": "SKU-001", "quantity": 2,
    "unit_price": 10.5,
}])
assert confirmed["order_id"] == "sanitizer-confirmed"
assert confirmed["status"] == "CONFIRMED"
assert confirmed["total_amount"] == 21
assert confirmed["confirmed_items"][0]["status"] == "CONFIRMED"
missing = process("sanitizer-out-of-stock", [{
    "item_id": "item-x", "sku": "UNKNOWN", "quantity": 1,
    "unit_price": 3,
}])
assert missing["status"] == "PARTIALLY_CONFIRMED"
assert missing["confirmed_items"][0]["status"] == "OUT_OF_STOCK"
assert missing["confirmed_items"][0]["reserved"] is False
print("cppboostexample sanitizer integration: PASS")
PY

kill -TERM "$order_pid"
wait "$order_pid"
order_pid=""
kill -TERM "$inventory_pid"
wait "$inventory_pid"
inventory_pid=""
