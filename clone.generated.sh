#!/usr/bin/env bash
# clone.generated.sh — restore separately published Go services and modules.
# Other languages keep every component in the project repository.
#
# Usage: bash clone.generated.sh

set -euo pipefail

clone_if_missing() {
    local dir="$1"
    local repo="$2"
    local revision="$3"
    if [ -d "$dir" ]; then
        echo "  skip  $dir (already present)"
    else
        echo "  clone $repo@$revision → $dir"
        git clone --branch "$revision" --depth 1 "$repo" "$dir"
    fi
}

echo "==> Cloning services..."

echo "==> Cloning modules..."

echo "==> Done."