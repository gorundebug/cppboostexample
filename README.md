# Example

Generated ServiceLib project. The root is a development workspace and an
orchestration layer; every service directory owns its build, Docker and
debugging commands and can be packaged or checked out independently.

## Services


- [`analyticsservice`](./analyticsservice/README.md) — Analytics Service

- [`automationservice`](./automationservice/README.md) — Automation Service

- [`inventoryservice`](./inventoryservice/README.md) — Inventory Service

- [`orderservice`](./orderservice/README.md) — Order Service


## Prerequisites

- Git;
- GNU Make;
- Docker with Docker Compose v2;
- language toolchains only for host-side build, test, lint or formatting
  commands. Docker runtime builds do not require host language toolchains.

Run `make help` to list the targets generated for the languages present in this
project.

Every command below states its execution environment explicitly: `[host]`
uses the caller's language toolchain, `[Docker]` executes through containers,
and `[mixed]` orchestrates both according to the languages in this project.

## First local run

```sh
make init        # [mixed] install tooling, generate sources, and format them
make docker-up   # [Docker] build copied-source runtime images and start the stack
```

The project Makefile explicitly uses `USE_LOCAL_MODULES=1`, so a freshly
generated project builds against its sibling contract/model modules without
publishing them first. `make docker-up` builds production-style runtime images
from copied sources, generates Grafana dashboards and starts the complete
project infrastructure and all services.

```sh
make build             # [mixed] build every service without starting it
make test              # [mixed] run every language test suite
make docker-down       # [Docker] stop the runtime stack, preserve volumes
make docker-restart    # [Docker] rebuild and restart the runtime stack
make docker-clean      # [Docker] stop the stack and remove project volumes
```

Generated `scripts/*.generated.sh` files are implementation details behind
these Make targets. Use `make help` as the public command index and invoke a
generated script directly only while diagnosing that script itself.

## Build modes

Runtime, development and debugger modes are intentionally separate:

```sh
make docker-build      # [Docker] build autonomous runtime images from copied sources
make docker-up         # [Docker] build and start the complete runtime stack
make docker-up-dev     # [Docker] build/start services with read-only source mounts
make docker-down-dev   # [Docker] stop the development stack

make debug-analyticsservice ANALYTICS_SERVICE_DEBUG_PORT=2345 # [Docker] debug only Analytics Service

make debug-automationservice AUTOMATION_SERVICE_DEBUG_PORT=2346 # [Docker] debug only Automation Service

make debug-inventoryservice INVENTORY_SERVICE_DEBUG_PORT=2347 # [Docker] debug only Inventory Service

make debug-orderservice ORDER_SERVICE_DEBUG_PORT=2348 # [Docker] debug only Order Service

```

A debug target changes only the selected service. Other services and shared
infrastructure keep their ordinary project configuration. Override the shown
host-port variable directly in the Make invocation to run several debuggers at
once; the debugger keeps listening on port `2345` inside each container.

Application listener ports and Docker host forwarding are independent:

| Service | Container HTTP | Host HTTP default | Container gRPC | Host gRPC default |
|---|---:|---:|---:|---:|
| Analytics Service | 9093 | 9093 | 9203 | 9203 |
| Automation Service | 9094 | 9094 | 9204 | 9204 |
| Inventory Service | 9092 | 9092 | 9202 | 9202 |
| Order Service | 9091 | 9091 | 9201 | 9201 |


`<SERVICE>_HTTP_PORT` and `<SERVICE>_GRPC_PORT` override the application
listeners and the container side of each mapping. `<SERVICE>_HOST_HTTP_PORT`
and `<SERVICE>_HOST_GRPC_PORT` override only the host side. For example,
`ORDER_SERVICE_HTTP_PORT=8080 ORDER_SERVICE_HOST_HTTP_PORT=18080 make
docker-up` makes the service listen on `8080` in its container and publishes it
as `localhost:18080`. Generated Dockerfiles deliberately do not use static
`EXPOSE` metadata for configurable ports.

## Local modules and published modules

There is no filesystem auto-detection and no fallback between modes:

- project commands default to `USE_LOCAL_MODULES=1`;
- a command run inside an independent service defaults to
  `USE_LOCAL_MODULES=0`;
- `USE_LOCAL_MODULES=1` requires every referenced unpublished module in the
  generated sibling layout;
- `USE_LOCAL_MODULES=0` resolves every module at the repository and revision
  pinned by the generated service.

To verify this workspace against published modules:

```sh
make build USE_LOCAL_MODULES=0
make test USE_LOCAL_MODULES=0
make docker-up USE_LOCAL_MODULES=0
```

To move a project from local to repository modules, publish the modules at the
version declared by the DSL, regenerate the project so every service pins that
version, then use `USE_LOCAL_MODULES=0`. Do not edit generated dependency files
by hand.

For a separately obtained service and separately obtained unpublished modules,
place them under one parent directory using their generated directory names:

```text
checkout/
  orderservice/
  inventory_service_api/
  model_<language>/
  order_service_api/
```

Then run the service's Make command explicitly in local mode, for example:

```sh
make -C orderservice build USE_LOCAL_MODULES=1
make -C orderservice docker-build USE_LOCAL_MODULES=1
```

## Quality and generated code

```sh
make gen             # [mixed] regenerate transport and schema-owned sources
make build           # [mixed] build every service
make test            # [mixed] run every service test suite
make lint            # [mixed] run all configured linters/type checks
make lint-fix        # [mixed] apply supported automatic fixes
make fmt             # [mixed] format generated-language sources
make ci              # [mixed] tools + build + test + lint
make integration-test # [Docker] run the integration stack and assertions
make clean           # [host] remove language build artifacts
```

## Regeneration and merge

The generator can update an existing project without overwriting business
code. Run merge commands from the project root:

```sh
make merge-check ARCHIVE=/absolute/path/project.zip # preview; do not change files
make merge ARCHIVE=/absolute/path/project.zip       # apply the generated archive
make merge-validate                                 # validate generated/business boundaries
```

`merge-check` is the safe command to use in CI or before accepting a generator
upgrade. Project-specific merge hooks and exclusions are documented next to
the generated merge scripts; do not edit generated files merely to preserve a
custom change.

## Publishing independent repositories

Each service and module is independently publishable; the project repository
is only their workspace and orchestration layer.

```sh
make git-push       # generate and push configured modules, services, and project
make git-init       # git-push, then synchronize language dependency manifests
make go-mod-sync    # Go only: synchronize manifests after publishing tags
```

Individual `git-push-<component>` targets are listed by `make help`. Destructive
`git-delete*` targets delete configured remote repositories and are never part
of build or regeneration. Review the resolved repository names before invoking
them.


### Go

```sh
make golang-build     # [host]
make golang-test      # [host]
make golang-lint      # [host]
make golang-lint-fix  # [host]
make golang-codegen   # [host]
make go-mod-sync      # [host]
```




### C++ / Boost

```sh
make cpp-build           # [Docker] Debug build
make cpp-test            # [Docker] Debug build and tests
make cpp-release-build   # [Docker] optimized build
make cpp-release-test    # [Docker] optimized build and tests
make cpp-asan-test       # [Docker] AddressSanitizer + UndefinedBehaviorSanitizer
make cpp-tsan-test       # [Docker] ThreadSanitizer
make cpp-lint            # [Docker]
make cpp-format          # [Docker]
make cpp-workspace-build # [Docker]
make cpp-workspace-test  # [Docker]
make cpp-package         # [host] package standalone service directories
```





## Optional dependency proxy

Proxy use is selected only by the caller environment and does not change local
module selection. Without `DEPENDENCY_PROXY_DIR`, builds use normal upstream
registries. With it, package, archive and Git downloads use the persistent
Nexus/Git-mirror stack and never bypass it.

```sh
export DEPENDENCY_PROXY_DIR=/absolute/path/to/dependency-proxy-data
make DEPENDENCY_PROXY_ACCEPT_EULA=true dependency-cache-up # [Docker] first start only
make dependency-cache-status       # [Docker]
make dependency-cache-refresh      # [Docker] refresh every mirrored Git repository
eval "$(make -s dependency-cache-env)" # [host] print/apply package-manager routing
make dependency-cache-docker-build # [Docker] prefetch/cache base images
make dependency-cache-down         # [Docker] preserve cached data
make dependency-cache-clean        # [Docker] delete all proxy and mirror data
```

Set `DEPENDENCY_PROXY_DIR` before every command that must use the proxy. Unset
it to use upstream registries directly. After publishing a new internal tag,
run `make dependency-cache-refresh` before a build that consumes that tag; a
failed refresh stops instead of silently serving an older revision. In either
mode download failures are retried but never routed through a hidden fallback.

See [`dependency-cache/README.generated.md`](./dependency-cache/README.generated.md)
for setup, routing, retry, Linux/macOS Docker-host details and cache
maintenance.

## Kubernetes

```sh
make kubernetes-up      # [Docker] build, deploy and verify the local cluster
make kubernetes-build   # [Docker] build and publish images to its local registry
make kubernetes-deploy  # [Docker] install infrastructure and service Helm releases
make kubernetes-test    # [Docker] verify rollouts and metrics
make kubernetes-status  # [Docker]
make kubernetes-down    # [Docker] preserve cluster volumes
make kubernetes-clean   # [Docker] remove the cluster and its volumes
```

The shorter `k8s-*` aliases provide the same operations. Kubernetes-specific
details are in
[`kubernetes/README.generated.md`](./kubernetes/README.generated.md).
