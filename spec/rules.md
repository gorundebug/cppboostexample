# Implementation Rules

These rules apply to every `spec/*/task*.md`. The generated graph and transport
contracts are the source of truth; business implementations and their tests are
user-owned extension points.

## Project invariants

- Project root: `example/`
- Graph: `example/graph/example.generated.yaml`
- Never edit a file whose name contains `generated`; those files are replaced
  during project merge.
- Never change generated signatures, topology wiring, IDs, config keys, or
  transport contracts in order to make an implementation easier.
- Change `.proto`/OpenAPI source and regenerate; never patch generated bindings.
- Preserve the message/stream context received from the framework.
- Do not keep mutable per-request state in function objects: function instances
  are created once and may process requests concurrently.
- Finish one task at a time and immediately copy its completion line to
  `spec/progress.md`.

## Services

| Service | Language | Directory |
|---------|----------|-----------|
| `Analytics Service` | `C++/Boost` | `analyticsservice/` |
| `Automation Service` | `Go` | `automationservice/` |
| `Inventory Service` | `C++/Boost` | `inventoryservice/` |
| `Order Service` | `C++/Boost` | `orderservice/` |


## Go rules

- Business functions are structs implementing the generated servicelib
  interfaces. Keep their generated method signatures.
- Pass the received `context.Context` to collectors, senders and callbacks.
  `context.Background()` and `context.TODO()` are forbidden in business paths.
- Makers may perform asynchronous initialization. Generated initializer groups
  run them through `errgroup`; they must honor cancellation and must not detach
  initialization work from the group.
- Preserve generated maker parameters and their order: cancellable group
  context, runtime environment, then the exact typed function, stream,
  endpoint, connector or service configuration. Runtime-owned router, handler
  or owner values are additional explicit typed arguments where required;
  makers must not recover these inputs from globals.
- Use generated `Makefile` targets:
  - regenerate: `make gen`
  - build: `make build`
  - test: `make test`
  - lint: `make lint`
- Implement generated `*_test.go` files.
- Import the public transformation API expected by the generated stub; do not
  bypass it by manually wiring runtime internals.





## C++/Boost rules

- Function objects must satisfy the concepts checked by generated stream
  construction. Keep the exact `operator()`/handler method surface in the
  generated user-owned header.
- Treat `servicelib::MessageContext` as request/message metadata and propagate
  it through collectors. Respect `Payload<T>` ownership; do not retain borrowed
  references beyond a synchronous call.
- C++ builds and tests are Docker-canonical:
  - build: `./scripts/build.generated.sh`
  - test: `./scripts/test.generated.sh`
  - lint: `./scripts/lint.generated.sh`
- Regenerate protobuf/OpenAPI bindings through the generated CMake/Docker
  workflow, never by invoking `protoc` or runtime-specific generators manually.
- Implement the adjacent `*_test.cpp` file with GoogleTest.
- Keep the generated Boost.Asio/Beast/asio-grpc coroutine and executor
  boundaries; blocking work belongs on its configured non-I/O task pool.
- Makers return `boost::asio::awaitable` and are scheduled concurrently on the
  generated Asio executor. Do not use `std::async` or a private thread pool.
- Do not modify `*_generated.hpp`, `*_generated.cpp`, generated protobuf, or
  generated OpenAPI sources.









## Temporal Workflow determinism

- A function reached from a `temporalExecutionType: Workflow` endpoint is
  replayed by Temporal. It must be deterministic even when the same code is
  also reachable from an ordinary process-side endpoint.
- Do not perform network or filesystem I/O, read process environment or wall
  clocks, generate unrestricted random values, access process-side stores, or
  start native threads, executors, goroutines, asyncio tasks, or detached
  promises from Workflow business code.
- Use the existing generated graph APIs. `Delay` selects the official Temporal
  Workflow timer automatically; `TaskPool` and `PriorityTaskPool` select the
  generated deterministic workflow-local schedulers.
- Emit logs, metrics and traces only through the framework interfaces supplied
  to the Workflow. They are backed by the official replay-safe SDK APIs; never
  call process exporters from Workflow code.
- Go Workflow code must pass the generated `golang-workflowcheck` target.
  Python Workflows run in the official default sandbox. TypeScript Workflows
  are bundled by the official SDK, but deterministic user code remains the
  author's responsibility.


## Endpoint and serialization rules

- External request/response types belong to protobuf/OpenAPI contracts.
- Internal stream types belong to the language backend's model package.
- Convert between external and internal types in endpoint handlers.
- Add serialization only where data crosses a process/storage boundary.
- For source endpoints, verify a real request and include the command in the
  task completion entry when the task asks for it.

## Priority of truth

1. Current task file.
2. Graph definition.
3. `.proto`/OpenAPI source contracts.
4. Generated type signatures.
5. servicelib runtime semantics for the selected language.