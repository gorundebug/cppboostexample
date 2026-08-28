# Automation Service

## Ports

- **HTTP**: `9094`
- **gRPC**: `9204`
## Endpoints

- **Metrics** (Prometheus): `GET http://localhost:9094/metrics`
- **Status** (topology visualization): `GET http://localhost:9094/status`

## Make commands

```bash
make build            # [host] generate owned protobuf code and build the service
make run              # [host] run with generated config files
make test             # [host] run Go tests
make lint             # [host] run golangci-lint
make lint-fix         # [host] apply supported golangci-lint fixes
make gen-proto        # [host] regenerate service-owned protobuf code
make fmt-proto        # [host] format service-owned .proto files
make act              # [Docker] run repository CI locally through act
make docker-build     # [Docker] build the autonomous runtime image from copied sources
make docker-up        # [Docker] build and start only this service
make docker-up-dev    # [Docker] start with this directory mounted read-only
make debug DEBUG_PORT=2345 # [Docker] start Delve; DEBUG_PORT is the host port
make docker-down      # [Docker] stop the standalone runtime stack
make docker-down-dev  # [Docker] stop the standalone development stack
make clean            # [host] remove Go build artifacts
make help             # [host] list the generated service targets
```

The service defaults to `USE_LOCAL_MODULES=0`: its framework and contract/model
modules are fetched from their pinned repositories. A generated project root
explicitly invokes the same targets with `USE_LOCAL_MODULES=1`.

For a separately obtained service plus unpublished modules, place all modules
next to this directory using their generated names and select local mode:

```bash
make build USE_LOCAL_MODULES=1
make docker-build USE_LOCAL_MODULES=1
```

After publishing those modules and regenerating this service with their pinned
version, omit the flag or pass `USE_LOCAL_MODULES=0`. Make never guesses the
mode from directories on disk.

Every debugger listens on `2345` inside its container. Set `DEBUG_PORT` in the
`make debug` command when another host port is needed.

The application listens on `9094` for HTTP and
`9204` for gRPC by default. Set
`AUTOMATION_SERVICE_HTTP_PORT` or
`AUTOMATION_SERVICE_GRPC_PORT` to change the listener and
container-side mapping. Set `AUTOMATION_SERVICE_HOST_HTTP_PORT`
or `AUTOMATION_SERVICE_HOST_GRPC_PORT` to change only the
forwarded host port.

Dependency proxy settings are independent and are read only when
`DEPENDENCY_PROXY_DIR` is present in the caller's environment.
