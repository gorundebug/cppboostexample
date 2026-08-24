#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/dependency-proxy-env.generated.sh"

# Build and start the generated services, then exercise the real
# HTTP -> graph -> gRPC -> graph -> HTTP path on the Compose network.
preset="${1:-docker-debug}"
case "$preset" in
  docker-debug|docker-release) ;;
  *)
    echo "unsupported C++ Docker preset: $preset" >&2
    exit 2
    ;;
esac

./scripts/build.generated.sh "$preset"

docker compose -f docker-compose.integration.generated.yml up -d --force-recreate
cleanup() {
  docker compose -f docker-compose.integration.generated.yml down --timeout 30
}
trap cleanup EXIT

docker compose -f docker-compose.cmake.generated.yml run --build --rm cpp-build \
  python3 - <<'PY'
import json
import time
import urllib.error
import urllib.request


def graph_is_ready(service, port):
    try:
        with urllib.request.urlopen(
            f"http://{service}:{port}/status/data", timeout=0.5
        ) as response:
            graph = json.load(response)
            return (
                response.status == 200
                and isinstance(graph.get("nodes"), list)
                and isinstance(graph.get("edges"), list)
                and bool(graph["nodes"])
            )
    except (OSError, ValueError, urllib.error.URLError):
        return False


for attempt in range(300):
    if graph_is_ready("orderservice", 9091) and graph_is_ready(
        "inventoryservice", 9092
    ):
        break
    if attempt == 299:
        raise RuntimeError("generated services did not become ready")
    time.sleep(0.1)


def process(request_id, items):
    request = urllib.request.Request(
        "http://orderservice:9091/v1/processorder",
        data=json.dumps({"customer_id": "integration", "items": items}).encode(),
        headers={
            "Content-Type": "application/json",
            "X-Request-ID": request_id,
            "traceparent":
                "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01",
            "tracestate": "integration=generated",
            "baggage": "test-suite=generated-integration",
        },
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=10) as response:
        assert response.status == 200
        return json.load(response)


confirmed = process("generated-confirmed", [{
    "item_id": "item-1", "sku": "SKU-001", "quantity": 2,
    "unit_price": 10.5,
}])
assert confirmed["order_id"] == "generated-confirmed"
assert confirmed["status"] == "CONFIRMED"
assert confirmed["total_amount"] == 21
assert len(confirmed["confirmed_items"]) == 1
assert confirmed["confirmed_items"][0]["status"] == "CONFIRMED"
assert confirmed["confirmed_items"][0]["reserved"] is True

missing = process("generated-out-of-stock", [{
    "item_id": "item-x", "sku": "UNKNOWN", "quantity": 1,
    "unit_price": 3,
}])
assert missing["order_id"] == "generated-out-of-stock"
assert missing["status"] == "PARTIALLY_CONFIRMED"
assert len(missing["confirmed_items"]) == 1
assert missing["confirmed_items"][0]["status"] == "OUT_OF_STOCK"
assert missing["confirmed_items"][0]["reserved"] is False

print("cppboost generated integration scenario: PASS")
PY