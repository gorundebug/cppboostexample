#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/dependency-proxy-env.generated.sh"

preset="${1:-docker-debug}"
case "$preset" in
  docker-debug|docker-release) ;;
  *) echo "unsupported C++ Docker preset: $preset" >&2; exit 2 ;;
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

services = [
    ("analyticsservice", 9093),
    ("inventoryservice", 9092),
    ("orderservice", 9091),
]

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
    if all(graph_is_ready(service, port) for service, port in services):
        break
    if attempt == 299:
        raise RuntimeError("generated services did not become ready")
    time.sleep(0.1)

for service, port in services:
    for path in ("/health/startup", "/health/ready", "/health/live"):
        with urllib.request.urlopen(
            f"http://{service}:{port}{path}", timeout=5
        ) as response:
            assert response.status == 200

print("generated Boost C++ integration lifecycle: PASS")
PY