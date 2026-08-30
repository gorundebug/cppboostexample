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
    tsan_options="halt_on_error=1"
    for symbolizer in llvm-symbolizer-18 llvm-symbolizer; do
      if command -v "$symbolizer" >/dev/null 2>&1; then
        tsan_options+=":external_symbolizer_path=$(command -v "$symbolizer")"
        break
      fi
    done
    export TSAN_OPTIONS="$tsan_options"
    ;;
  *) echo "unsupported sanitizer: $sanitizer" >&2; exit 2 ;;
esac

service_dirs=(
  "."
)
service_names=(
  "analyticsservice"
)
service_targets=(
  "example_analytics_service"
)
http_ports=(
  "9093"
)

pids=()
stop_services() {
  local pid
  for pid in "${pids[@]}"; do kill -TERM "$pid" 2>/dev/null || true; done
  for pid in "${pids[@]}"; do wait "$pid" 2>/dev/null || true; done
  pids=()
}
terminate_services() { stop_services; exit 0; }
trap stop_services EXIT
trap terminate_services INT TERM

for index in "${!service_dirs[@]}"; do
  service_dir="${service_dirs[$index]}"
  service_name="${service_names[$index]}"
  target="${service_targets[$index]}"
  (
    cd "$service_dir"
    exec env SERVICELIB_NOOP_METRICS=1 \
      "${build_dir%/}/$target" \
      --config config/config.yaml \
      --values config/overrides.integration.generated.yaml \
      --workers 2
  ) &
  pids+=("$!")
done

http_ports_csv="$(IFS=,; echo "${http_ports[*]}")"
ready=0
ready_deadline=$((SECONDS + 120))
while (( SECONDS < ready_deadline )); do
  if HTTP_PORTS="$http_ports_csv" python3 - <<'PY' >/dev/null 2>&1
import json, os, urllib.request
for port in os.environ["HTTP_PORTS"].split(","):
    with urllib.request.urlopen(f"http://127.0.0.1:{port}/status/data", timeout=2) as response:
        graph = json.load(response)
        assert set(("nodes", "edges")) <= graph.keys()
        assert graph["nodes"]
PY
  then ready=1; break; fi
  for pid in "${pids[@]}"; do
    if ! kill -0 "$pid" 2>/dev/null; then
      echo "sanitized generated service exited before readiness" >&2
      exit 1
    fi
  done
  sleep 0.1
done
if [[ "$ready" -ne 1 ]]; then
  echo "sanitized generated services did not become ready" >&2
  exit 1
fi

HTTP_PORTS="$http_ports_csv" python3 - <<'PY'
import json, os, urllib.request
for port in os.environ["HTTP_PORTS"].split(","):
    for path in ("/health/startup", "/health/ready", "/health/live", "/status/data"):
        with urllib.request.urlopen(f"http://127.0.0.1:{port}{path}", timeout=5) as response:
            assert response.status == 200
            if path == "/status/data":
                graph = json.load(response)
                assert isinstance(graph["nodes"], list)
                assert isinstance(graph["edges"], list)
                assert graph["nodes"]
print("generated Boost C++ sanitizer runtime gate: PASS")
PY

if [[ "${SANITIZER_HOLD:-0}" == "1" ]]; then
  wait -n "${pids[@]}"
  exit $?
fi

status=0
for pid in "${pids[@]}"; do kill -TERM "$pid" 2>/dev/null || true; done
for pid in "${pids[@]}"; do if ! wait "$pid"; then status=1; fi; done
pids=()
exit "$status"