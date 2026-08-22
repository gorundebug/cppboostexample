#!/usr/bin/env bash
set -euo pipefail

# Repository-only entry point: restore generated service/module checkouts,
# build and test both services, then exercise the live HTTP -> gRPC graph.
# SERVICELIB_SOURCE_CONTEXT may point at a local framework checkout; when it is
# absent Compose fetches the pinned framework repository and revision.

for tool in git docker; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "missing prerequisite: $tool" >&2
    exit 1
  fi
done
if ! docker compose version >/dev/null 2>&1; then
  echo "missing prerequisite: docker compose plugin" >&2
  exit 1
fi

bash ./clone.generated.sh
./scripts/test.generated.sh docker-release
./scripts/integration-test.generated.sh docker-release

echo "cppboostexample clean-machine quickstart: PASS"