# Automation Service

## Ports

- **HTTP**: `9094`
- **gRPC**: `9204`
## Endpoints

- **Metrics** (Prometheus): `GET http://localhost:9094/metrics`
- **Status** (topology visualization): `GET http://localhost:9094/status`

## Make commands

```bash
make build            # generate owned protobuf code and build the service
make run              # run on the host with generated config files
make test             # run Go tests
make lint             # run golangci-lint
make lint-fix         # apply supported golangci-lint fixes
make gen-proto        # regenerate service-owned protobuf code
make fmt-proto        # format service-owned .proto files
make act              # run repository CI locally through act
make docker-build     # build the autonomous runtime image from copied sources
make docker-up        # build and start only this service
make docker-up-dev    # start with this directory mounted read-only
make debug DEBUG_PORT=2345 # start Delve; DEBUG_PORT is the host forwarding port
make docker-down      # stop the standalone runtime stack
make docker-down-dev  # stop the standalone development stack
make clean            # remove Go build artifacts
make help             # list the generated service targets
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