#!/usr/bin/env bash
set -euo pipefail

exec docker compose -f docker-compose.cmake.generated.yml run --build --rm cpp-build \
  /bin/bash -lc '
    source scripts/configure-git-auth.generated.sh
    cmake --preset docker-debug \
      -DSERVICEGEN_FETCH_CPP_DEPENDENCIES="${SERVICEGEN_FETCH_CPP_DEPENDENCIES:-OFF}" \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

    mapfile -d "" sources < <(
      find . -path ./build -prune -o -type f \
        \( -name "*.cpp" -o -name "*.hpp" -o -name "*.h" \) -print0
    )
    if ((${#sources[@]})); then
      clang-format --dry-run --Werror "${sources[@]}"
    fi

    mapfile -d "" translation_units < <(
      find . -path ./build -prune -o -type f -name "*.cpp" -print0
    )
    for source in "${translation_units[@]}"; do
      clang-tidy -p /workspace/build "$source"
    done
  '