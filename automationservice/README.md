# Automation Service

## Ports

- **HTTP**: `9094`
- **gRPC**: `9204`
## Endpoints

- **Metrics** (Prometheus): `GET http://localhost:9094/metrics`
- **Status** (topology visualization): `GET http://localhost:9094/status`

## Make commands

```bash
make build               # build the service
make run                 # run locally
make test                # run tests
make lint                # run golangci-lint (auto-installs if missing)
make gen-proto           # generate protobuf code
make fmt-proto           # format .proto files
make act                 # run CI locally via act (requires Docker)
make docker-build        # build Docker image
make docker-build-local  # build Docker image for local dev
make clean               # remove build artifacts
```