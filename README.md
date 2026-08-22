# C++ Boost ServiceLib example

Generated order-processing example for `cppboostservicelib`.

This project mirrors the directory and semantic contract of `cppexample` while
using Boost.Asio, Boost.Beast and asio-grpc instead of userver.

The Docker C++ toolchain enables `ccache` automatically and keeps downloaded
`apt` packages in the local BuildKit cache. Repeated builds reuse dependency
downloads and compiled objects. Override the default 20 GiB compiler-cache
limit with, for example, `CCACHE_MAXSIZE=40G make cpp-build`.

## Clean-machine quickstart

After cloning only this repository, run:

```sh
./scripts/quickstart.generated.sh
```

All service and module sources are part of this repository. The script performs
the complete Docker Release unit build, starts both services and verifies the live
HTTP-to-gRPC order scenario. Docker fetches the pinned framework revision when
`SERVICELIB_SOURCE_CONTEXT` is absent. To test unpublished framework changes,
point that variable at an absolute local `cppboostservicelib` checkout.

For a minimal Release image containing only service binaries, their runtime
libraries, and configuration, run `make docker-up RUNTIME_IMAGE=1`. It removes
source/build mounts, debugger ports, and build tools. Benchmark and profiling
tools select this mode automatically. Plain `make docker-up` keeps the
development layout.

## Optional order analytics through Kafka

The shared `orderProcessed` Kafka endpoint is disabled in Order Service by
default and creates no producer while disabled. Enable it in
`orderservice/config/overrides.yaml`:

```yaml
endpoints:
  orderProcessed:
    enabled: true
```

The Analytics Service consumes `order-processed`, counts successful and
unsuccessful orders, and uses the included Redpanda broker.

## Sanitizer gates

Run the complete generated unit/config and live HTTP-to-gRPC gates against a
local framework checkout:

```sh
SERVICELIB_SOURCE_CONTEXT=/absolute/path/to/cppboostservicelib \
  ./scripts/sanitizer-test.generated.sh asan

SERVICELIB_SOURCE_CONTEXT=/absolute/path/to/cppboostservicelib \
  ./scripts/sanitizer-test.generated.sh tsan
```

The scripts build the pinned protobuf/gRPC host code generators separately,
then instrument the complete runtime dependency stack and both services. All
builds use unrestricted `--parallel`; ASan also enables UBSan and leak checks.

Dependency download progress is visible by default. Framework consumers can
disable the detailed Git progress with
`-DCPPBOOSTSERVICELIB_FETCH_PROGRESS=OFF`; the sanitizer gate deliberately
forces `-DFETCHCONTENT_QUIET=OFF` so a clean-machine build cannot appear stuck.
