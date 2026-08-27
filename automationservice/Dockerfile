# syntax=docker/dockerfile:1.7

# Stage 1: Build
FROM servicelib-source AS servicelib-source

FROM golang:1.25-bookworm AS builder

ARG SERVICE_DIR=.
ARG TARGETARCH
ARG SERVICEGEN_RUNTIME_STRIP=ON
ARG SERVICEGEN_GITHUB_RAW_URL=https://github.com
ENV SERVICEGEN_GITHUB_RAW_URL=${SERVICEGEN_GITHUB_RAW_URL}
COPY dependency-download-mirrors.generated.env /etc/servicegen/dependency-download-mirrors.generated.env
COPY dependency-download-mirrors.env /etc/servicegen/dependency-download-mirrors.env
COPY dependency-download-env.generated.sh /usr/local/bin/servicegen-download-env
SHELL ["/usr/local/bin/servicegen-download-env", "/bin/sh", "-c"]
ARG GOPROXY=https://proxy.golang.org,direct
ENV GOPROXY=${GOPROXY}
ARG GOSUMDB=sum.golang.org
ENV GOSUMDB=${GOSUMDB}
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
    cp -a "$source_dir/." /servicelib/
COPY . /workspace
WORKDIR /workspace/${SERVICE_DIR}
RUN if [ -f /workspace/go.work ]; then \
      cd /workspace \
      && go work edit \
        -replace github.com/gorundebug/servicelib=/servicelib; \
    else \
      go mod edit \
        -replace github.com/gorundebug/servicelib=/servicelib; \
    fi
RUN --mount=type=cache,id=servicegen-go-mod-v1-${TARGETARCH},target=/go/pkg/mod,sharing=locked \
    go mod download
RUN --mount=type=cache,id=servicegen-go-mod-v1-${TARGETARCH},target=/go/pkg/mod,sharing=locked \
    --mount=type=cache,id=servicegen-go-build-v1-${TARGETARCH},target=/root/.cache/go-build,sharing=locked \
    if [ "${SERVICEGEN_RUNTIME_STRIP}" = "ON" ]; then \
      GO_LINKER_FLAGS="-s -w"; \
    else \
      GO_LINKER_FLAGS=""; \
    fi \
    && CGO_ENABLED=0 GOOS=linux go build -ldflags="${GO_LINKER_FLAGS}" -o /app/service ./cmd/service/main.go

# Replay target: compile the generated history checker with the same sources
# and dependency cache as the service, without adding it to the runtime image.
FROM builder AS temporal-replay
RUN --mount=type=cache,id=servicegen-go-mod-v1-${TARGETARCH},target=/go/pkg/mod,sharing=locked \
    --mount=type=cache,id=servicegen-go-build-v1-${TARGETARCH},target=/root/.cache/go-build,sharing=locked \
    CGO_ENABLED=0 GOOS=linux go build -o /app/temporal-replay ./cmd/temporal-replay

# Stage 2: Runtime
FROM debian:bookworm-slim AS runtime

ARG SERVICE_DIR=.
ARG TARGETARCH
ARG SERVICEGEN_APT_DEBIAN_URL=
ARG SERVICEGEN_APT_DEBIAN_SECURITY_URL=
RUN if [ -n "$SERVICEGEN_APT_DEBIAN_URL$SERVICEGEN_APT_DEBIAN_SECURITY_URL" ]; then \
      find /etc/apt -type f \( -name '*.list' -o -name '*.sources' \) -exec sed -i \
        -e "s|http://deb.debian.org/debian-security|$SERVICEGEN_APT_DEBIAN_SECURITY_URL|g" \
        -e "s|http://deb.debian.org/debian|$SERVICEGEN_APT_DEBIAN_URL|g" {} +; \
    fi
RUN rm -f /etc/apt/apt.conf.d/docker-clean
RUN --mount=type=cache,id=servicegen-go-apt-lists-v1-${TARGETARCH},target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,id=servicegen-go-apt-cache-v1-${TARGETARCH},target=/var/cache/apt,sharing=locked \
    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates wget

WORKDIR /app

COPY --from=builder /app/service .
COPY ${SERVICE_DIR}/config/ ./config/

EXPOSE 9094
EXPOSE 9204

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO/dev/null http://localhost:9094/status || exit 1

ENTRYPOINT ["./service", "-config", "./config/config.yaml", "-values", "./config/overrides.yaml"]