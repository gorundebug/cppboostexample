#!/usr/bin/env bash
set -euo pipefail

project_name="cppboostexample-race"
services=(
  "automationservice"
)
stop_timeout="${RACE_STOP_TIMEOUT:-7}"
compose=(docker compose --project-name "$project_name" -f docker-compose.yml -f docker-compose.golang-race.generated.yml)
status=0
action="${1:-down}"

if [[ "$action" == "stop" || "$action" == "down" ]]; then
  containers=""
  for service in "${services[@]}"; do
    container_id="$("${compose[@]}" ps -q "$service" | head -n 1)"
    [[ -z "$container_id" ]] || containers="$containers $container_id"
  done
  if [[ -n "$containers" ]]; then
    # Container IDs contain no shell metacharacters or whitespace. Expanding
    # this list once is what makes Docker deliver one signal operation to the
    # complete service set.
    docker kill --signal SIGTERM $containers >/dev/null || status=1
  fi
  deadline=$((SECONDS + stop_timeout))
  running="$containers"
  while [[ -n "$running" && $SECONDS -lt $deadline ]]; do
    next=""
    for container_id in $running; do
      [[ "$(docker inspect -f '{{.State.Running}}' "$container_id" 2>/dev/null || true)" == "true" ]] && next="$next $container_id"
    done
    running="$next"
    [[ -z "$running" ]] || sleep 0.1
  done
  if [[ -n "$running" ]]; then
    echo "Go race services exceeded the shared ${stop_timeout}s shutdown limit: $running" >&2
    docker kill --signal SIGKILL $running >/dev/null 2>&1 || true
    status=1
  fi

  for service in "${services[@]}"; do
    logs="$(mktemp)"
    "${compose[@]}" logs --no-color "$service" >"$logs" 2>&1 || true
    if grep -Eq 'WARNING: DATA RACE|Found [0-9]+ data race' "$logs"; then
      echo "Go race detector reported a race in $service" >&2
      cat "$logs" >&2
      status=1
    fi
    container_id="$("${compose[@]}" ps -aq "$service" | head -n 1)"
    if [[ -n "$container_id" ]]; then
      exit_code="$(docker inspect -f '{{.State.ExitCode}}' "$container_id")"
      if [[ "$exit_code" != "0" ]]; then
        echo "Go race service $service exited with code $exit_code" >&2
        cat "$logs" >&2
        status=1
      fi
    fi
    rm -f "$logs"
  done
fi

if [[ "$action" == "clean" || "$action" == "down" ]]; then
  "${compose[@]}" down --timeout "$stop_timeout" --volumes --remove-orphans || status=1
fi
exit "$status"