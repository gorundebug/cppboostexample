#!/usr/bin/env bash
set -euo pipefail

exec docker compose -f docker-compose.cmake.generated.yml run --build --rm cpp-build \
  /bin/bash -lc '
    mapfile -d "" sources < <(
      find . -path ./build -prune -o -type f \
        \( -name "*.cpp" -o -name "*.hpp" -o -name "*.h" \) -print0
    )
    if ((${#sources[@]})); then
      clang-format -i "${sources[@]}"
    fi
  '