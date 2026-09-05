ARG DEPENDENCY_DOCKER_REGISTRY=docker.io

# Stage 1: Build
FROM servicelib-source AS servicelib-source
FROM module-model_go-source AS module-model_go-source

FROM ${DEPENDENCY_DOCKER_REGISTRY}/library/golang:1.25.4-bookworm AS builder

ARG SERVICE_DIR=.
ARG TARGETARCH
ARG RUNTIME_STRIP=ON
ARG PROTOC_VERSION=29.3
ARG PROTOC_GEN_GO_VERSION=v1.36.3
ARG PROTOC_GEN_GO_GRPC_VERSION=v1.5.1
ARG OAPI_CODEGEN_VERSION=v2.4.1
ARG DEPENDENCY_GITHUB_RAW_URL=https://github.com
ENV DEPENDENCY_GITHUB_RAW_URL=${DEPENDENCY_GITHUB_RAW_URL}
COPY dependency-download-mirrors.generated.env /etc/servicegen/dependency-download-mirrors.generated.env
COPY dependency-download-mirrors.env /etc/servicegen/dependency-download-mirrors.env
COPY dependency-download-env.generated.sh /usr/local/bin/servicegen-download-env
COPY prepare-local-build.generated.sh /usr/local/bin/prepare-local-build
SHELL ["/usr/local/bin/servicegen-download-env", "/bin/sh", "-c"]
ARG GOPROXY=https://proxy.golang.org,direct
ENV GOPROXY=${GOPROXY}
ARG GOSUMDB=sum.golang.org
ENV GOSUMDB=${GOSUMDB}
ARG DEPENDENCY_APT_DEBIAN_URL=
ARG DEPENDENCY_APT_DEBIAN_SECURITY_URL=
RUN if [ -n "$DEPENDENCY_APT_DEBIAN_URL$DEPENDENCY_APT_DEBIAN_SECURITY_URL" ]; then \
      find /etc/apt -type f \( -name '*.list' -o -name '*.sources' \) -exec sed -i \
        -e "s|http://deb.debian.org/debian-security|$DEPENDENCY_APT_DEBIAN_SECURITY_URL|g" \
        -e "s|http://deb.debian.org/debian|$DEPENDENCY_APT_DEBIAN_URL|g" {} +; \
    fi
RUN rm -f /etc/apt/apt.conf.d/docker-clean
RUN --mount=type=cache,id=servicegen-go-tool-apt-lists-${TARGETARCH},target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,id=servicegen-go-tool-apt-cache-${TARGETARCH},target=/var/cache/apt,sharing=locked \
    apt-get -o Acquire::http::Timeout=30 -o Acquire::https::Timeout=30 -o Acquire::Retries=2 update \
    && DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::http::Timeout=30 -o Acquire::https::Timeout=30 -o Acquire::Retries=2 install -y --no-install-recommends \
       ca-certificates curl make unzip \
    && case "${TARGETARCH}" in \
         amd64) protoc_arch=x86_64 ;; \
         arm64) protoc_arch=aarch_64 ;; \
         *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
       esac \
    && curl --fail --location --silent --show-error --connect-timeout 15 --speed-limit 1024 --speed-time 30 --retry 2 --retry-delay 2 --retry-max-time 30 --retry-all-errors \
       "${DEPENDENCY_GITHUB_RAW_URL}/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-${protoc_arch}.zip" \
       --output /tmp/protoc.zip \
    && unzip -q /tmp/protoc.zip bin/protoc -d /usr/local \
    && rm -f /tmp/protoc.zip
RUN --mount=type=cache,id=servicegen-go-mod-v1-${TARGETARCH},target=/go/pkg/mod,sharing=locked \
    servicegen-download-env --retry env GOBIN=/usr/local/bin go install google.golang.org/protobuf/cmd/protoc-gen-go@${PROTOC_GEN_GO_VERSION} \
    && servicegen-download-env --retry env GOBIN=/usr/local/bin go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@${PROTOC_GEN_GO_GRPC_VERSION} \
    && servicegen-download-env --retry env GOBIN=/usr/local/bin go install github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen@${OAPI_CODEGEN_VERSION}
COPY --from=servicelib-source / /tmp/servicelib-source
RUN set -eu; \
    source_dir=/tmp/servicelib-source; \
    archive=$(find "$source_dir" -mindepth 1 -maxdepth 1 -type f \( -name context -o -name '*.tar' -o -name '*.tar.gz' -o -name '*.tgz' -o -name '*.tar.xz' \) -print -quit); \
    if [ -n "$archive" ]; then \
      mkdir -p /tmp/servicelib-archive; \
      tar -xf "$archive" -C /tmp/servicelib-archive; \
      source_dir=/tmp/servicelib-archive; \
    fi; \
    manifest="$source_dir/go.mod"; \
    if [ ! -f "$manifest" ]; then manifest=$(find "$source_dir" -mindepth 2 -maxdepth 2 -type f -name go.mod -print -quit); fi; \
    if [ -z "$manifest" ]; then echo "servicelib source context has no go.mod" >&2; exit 1; fi; \
    source_dir=${manifest%/go.mod}; \
    if [ -z "$source_dir" ] || [ "$source_dir" = "/" ]; then echo "unsafe servicelib source directory" >&2; exit 1; fi; \
    mkdir -p /servicelib; \
    cp -R "$source_dir/." /servicelib/
COPY --from=module-model_go-source / /tmp/module-model_go-source
RUN set -eu; source_dir=/tmp/module-model_go-source; \
	if [ ! -f "$source_dir/go.mod" ] && [ -f "$source_dir/model_go/go.mod" ]; then \
	  source_dir="$source_dir/model_go"; \
	fi; \
    manifest="$source_dir/go.mod"; \
    if [ ! -f "$manifest" ]; then manifest=$(find "$source_dir" -mindepth 2 -maxdepth 2 -type f -name go.mod -print -quit); fi; \
    if [ -z "$manifest" ]; then echo "module context github.com/gorundebug/cppboostexample/model_go has no go.mod" >&2; exit 1; fi; \
    source_dir=${manifest%/go.mod}; mkdir -p /modules/model_go; cp -R "$source_dir/." /modules/model_go/
RUN set -eu; \
    for module in /modules/*; do \
      if [ -f "$module/Makefile" ]; then \
        make -C "$module" all TOOLS_DIR=/usr/local/bin \
          PROTOC=/usr/local/bin/protoc OAPI_CODEGEN=/usr/local/bin/oapi-codegen; \
      fi; \
    done
COPY . /workspace
WORKDIR /workspace
RUN go mod edit -replace github.com/gorundebug/servicelib=/servicelib \
    && go mod edit -replace github.com/gorundebug/cppboostexample/model_go=/modules/model_go \
    && true
RUN make -f make.generated.mk gen-proto TOOLS_DIR=/usr/local/bin PROTOC=/usr/local/bin/protoc
RUN --mount=type=cache,id=servicegen-go-mod-v1-${TARGETARCH},target=/go/pkg/mod,sharing=locked \
    go mod download all

# Source-mounted local development stops at this stage. The ordinary
# docker-build path continues in compiler and copies only the resulting binary
# into the runtime image.
FROM builder AS development
RUN servicegen-download-env --retry go install github.com/go-delve/delve/cmd/dlv@v1.25.2

FROM builder AS compiler
# The generated source tree intentionally contains no environment-specific
# go.sum. Resolve the local source-context graph only inside this disposable
# builder layer; the user's checked-out go.mod is never mutated.
RUN --mount=type=cache,id=servicegen-go-mod-v1-${TARGETARCH},target=/go/pkg/mod,sharing=locked \
    --mount=type=cache,id=servicegen-go-build-v1-${TARGETARCH},target=/root/.cache/go-build,sharing=locked \
    if [ "${RUNTIME_STRIP}" = "ON" ]; then \
      GO_LINKER_FLAGS="-s -w"; \
    else \
      GO_LINKER_FLAGS=""; \
    fi \
    && CGO_ENABLED=0 GOOS=linux go build -mod=mod -ldflags="${GO_LINKER_FLAGS}" -o /app/service ./cmd/service/main.go

# The race image is a real runtime build, not a unit-test-only probe. Go's race
# detector requires CGO and therefore deliberately uses the pinned Debian
# toolchain from the ordinary builder stage.
FROM builder AS race-compiler
RUN --mount=type=cache,id=servicegen-go-mod-v1-${TARGETARCH},target=/go/pkg/mod,sharing=locked \
    --mount=type=cache,id=servicegen-go-race-build-v1-${TARGETARCH},target=/root/.cache/go-build,sharing=locked \
    CGO_ENABLED=1 GOOS=linux go build -mod=mod -race -o /app/service ./cmd/service/main.go

# Replay target: compile the generated history checker with the same sources
# and dependency cache as the service, without adding it to the runtime image.
FROM compiler AS temporal-replay
RUN --mount=type=cache,id=servicegen-go-mod-v1-${TARGETARCH},target=/go/pkg/mod,sharing=locked \
    --mount=type=cache,id=servicegen-go-build-v1-${TARGETARCH},target=/root/.cache/go-build,sharing=locked \
    CGO_ENABLED=0 GOOS=linux go build -o /app/temporal-replay ./cmd/temporal-replay

# Stage 2: Runtime
FROM ${DEPENDENCY_DOCKER_REGISTRY}/library/debian:bookworm-slim AS runtime

ARG SERVICE_DIR=.
ARG TARGETARCH
ARG DEPENDENCY_APT_DEBIAN_URL=
ARG DEPENDENCY_APT_DEBIAN_SECURITY_URL=
RUN if [ -n "$DEPENDENCY_APT_DEBIAN_URL$DEPENDENCY_APT_DEBIAN_SECURITY_URL" ]; then \
      find /etc/apt -type f \( -name '*.list' -o -name '*.sources' \) -exec sed -i \
        -e "s|http://deb.debian.org/debian-security|$DEPENDENCY_APT_DEBIAN_SECURITY_URL|g" \
        -e "s|http://deb.debian.org/debian|$DEPENDENCY_APT_DEBIAN_URL|g" {} +; \
    fi
RUN rm -f /etc/apt/apt.conf.d/docker-clean
RUN --mount=type=cache,id=servicegen-go-apt-lists-v1-${TARGETARCH},target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,id=servicegen-go-apt-cache-v1-${TARGETARCH},target=/var/cache/apt,sharing=locked \
    apt-get -o Acquire::http::Timeout=30 -o Acquire::https::Timeout=30 -o Acquire::Retries=2 update \
    && DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::http::Timeout=30 -o Acquire::https::Timeout=30 -o Acquire::Retries=2 install -y --no-install-recommends ca-certificates wget

WORKDIR /app

COPY --from=compiler /app/service .
COPY ${SERVICE_DIR}/config/ ./config/

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO/dev/null http://localhost:${AUTOMATION_SERVICE_HTTP_PORT:-9094}/status || exit 1

ENTRYPOINT ["./service", "-config", "./config/config.yaml", "-values", "./config/overrides.yaml"]

# Keep the same runtime filesystem, configuration and entrypoint as production;
# only the executable is replaced by the race-instrumented build.
FROM runtime AS race
COPY --from=race-compiler /app/service /app/service
ENV GORACE=halt_on_error=1