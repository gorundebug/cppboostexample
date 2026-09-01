#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/dependency-proxy-env.generated.sh"

# Docker selects the native linux/amd64 or linux/arm64 image automatically.
# Pass an optional Compose command, for example:
#   ./scripts/cmake-docker.generated.sh build cpp-build
if (($# == 0)); then
  set -- run --build --rm cpp-build
fi

exec docker compose -f docker-compose.cmake.generated.yml "$@"