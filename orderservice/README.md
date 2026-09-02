# Order Service

Standalone generated Boost C++ service. All compile, test and runtime commands
use the generated Docker toolchain, so the host needs only Make, Docker and
Docker Compose v2.

```bash
make build          # [Docker] Debug compile check from copied sources; no start
make test           # [Docker] Debug build and unit tests from copied sources
make release-build  # [Docker] alias of make docker-build
make release-test   # [Docker] alias of make test
make asan-test      # [Docker] AddressSanitizer + UndefinedBehaviorSanitizer
make tsan-test      # [Docker] ThreadSanitizer
make lint           # [host] clang-format and clang-tidy checks of an existing build
make fmt            # [host] format C++ sources
make docker-build   # [Docker] build the optimized autonomous runtime image
make docker-up      # [Docker] build and start only this service
make docker-up-dev  # [Docker] start with sources mounted read-only
make debug DEBUG_PORT=2345 # [Docker] start gdbserver using this host port
make docker-down    # [Docker] stop the standalone runtime stack
make docker-down-dev # [Docker] stop the standalone development stack
make docker-clean   # [Docker] stop and remove standalone volumes/build state
make help           # [host] list generated targets
```

Sanitizer targets compile the complete statically linked dependency graph as
optimized `Release` code with explicit debug symbols and frame pointers and
without stripping. ASan+UBSan and TSan use standard Conan/compiler settings
and upstream-supported build options; third-party source code is never patched.

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

The default application listeners are HTTP `9091`
and gRPC `9201`. The generated
`ORDER_SERVICE_HTTP_PORT` and
`ORDER_SERVICE_GRPC_PORT` variables change the
listener and container-side mapping; the corresponding `_HOST_HTTP_PORT` and
`_HOST_GRPC_PORT` variables change only host forwarding.