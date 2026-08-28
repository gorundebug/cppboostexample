# Inventory Service

Standalone generated Boost C++ service. All compile, test and runtime commands
use the generated Docker toolchain, so the host needs only Make, Docker and
Docker Compose v2.

```bash
make build          # Debug build from copied sources
make test           # Debug build and unit tests
make release-build  # optimized autonomous runtime image
make release-test   # optimized build and tests
make asan-test      # AddressSanitizer + UndefinedBehaviorSanitizer
make tsan-test      # ThreadSanitizer
make lint           # clang-format and clang-tidy checks
make fmt            # format C++ sources
make docker-build   # build the production-style runtime image
make docker-up      # build and start only this service
make docker-up-dev  # start with sources mounted read-only
make debug DEBUG_PORT=2345 # start gdbserver using this host port
make docker-down
make docker-down-dev
make docker-clean   # stop and remove standalone volumes/build state
make help
```

The service defaults to repository modules (`USE_LOCAL_MODULES=0`). A generated
project passes `USE_LOCAL_MODULES=1`. The same local mode works for a separately
obtained service when all unpublished contract/model modules are placed next to
it using their generated directory names:

```bash
make build USE_LOCAL_MODULES=1
make docker-build USE_LOCAL_MODULES=1
```

After publishing and pinning those modules, omit the flag or explicitly use
`USE_LOCAL_MODULES=0`. Make does not auto-detect sibling modules. Proxy routing
is independent and is enabled only by the caller's `DEPENDENCY_PROXY_DIR`.
`gdbserver` always listens on `2345` inside the container; `DEBUG_PORT` selects
the forwarded host port.

The default application listeners are HTTP `9092`
and gRPC `9202`. The generated
`INVENTORY_SERVICE_HTTP_PORT` and
`INVENTORY_SERVICE_GRPC_PORT` variables change the
listener and container-side mapping; the corresponding `_HOST_HTTP_PORT` and
`_HOST_GRPC_PORT` variables change only host forwarding.