#!/bin/sh
# Entrypoint for automationservice.
# When DEBUG=1 the service is started under the Delve headless debugger on
# port 2345. Connect your IDE remote debugger to localhost:2345.
# When DEBUG=0 (default) the service starts normally.
set -e

if [ "${DEBUG:-0}" = "1" ]; then
    echo "[entrypoint] debug mode — starting dlv headless on :2345"
    exec dlv \
        --listen=:2345 \
        --headless=true \
        --api-version=2 \
        --accept-multiclient \
        exec ./service -- "$@"
else
    exec ./service "$@"
fi