# Automation Service

## Ports

- **HTTP**: `9094`
- **gRPC**: `9204`
## Endpoints

- **Metrics** (Prometheus): `GET http://localhost:9094/metrics`
- **Status** (topology visualization): `GET http://localhost:9094/status`

## Generated service layout

`internal/app/service.generated.go` coordinates the lifecycle and contains named
structures for streams, makers, functions, endpoints, clients and servers.

| File in `internal/app` | Responsibility |
| --- | --- |
| `streams.generated.go` | All streams, globally ordered construction, result bindings and cycle links. |
| `makers.generated.go` | Business and transport constructors; defaults can be customized in `service.go`. |
| `functions.generated.go` | One instance per shared business function; ordered initialization groups, parallel within each group. |
| `endpoints.generated.go` | Endpoint adapters and independent consumers, even when their business function is shared. |
| `clients.generated.go` | Outbound clients and connection cleanup. |
| `servers.generated.go` | HTTP/gRPC registration, startup and transport draining. |
| `connectors.generated.go` | Connector initialization; the runtime owns the resources. |
| `substreams.generated.go` | Service methods exposing callable SubStream handles. |
| `service_serde.generated.go` | Serialization registry and custom serde lookup. |

Pipelines group the model, not runtime ownership. Cross-pipeline connections use
the same dependency order as connections within a pipeline. Shared functions are
created once per service; an isolated Temporal Workflow graph owns its own instances.
Customize business logic and makers in user-owned files, not generated files.

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
make race-build       # [Docker] build this service independently with -race
make race-up          # [Docker] build and start this service with -race
make race-start       # [Docker] start its already-built race image
make race-down        # [Docker] validate race logs/exits and stop it
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