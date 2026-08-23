# syntax=docker/dockerfile:1
ARG SERVICEGEN_GRPC_SOURCE_STAGE=empty-source-cache
ARG SERVICEGEN_ASIO_GRPC_SOURCE_STAGE=empty-source-cache
FROM servicelib-source AS servicelib-source
FROM scratch AS empty-source-cache
FROM ${SERVICEGEN_GRPC_SOURCE_STAGE} AS grpc-source-context
FROM ${SERVICEGEN_ASIO_GRPC_SOURCE_STAGE} AS asio-grpc-source-context

FROM ubuntu:24.04 AS development

ARG TARGETARCH
ARG SERVICEGEN_APT_UBUNTU_ARCHIVE_URL=
ARG SERVICEGEN_APT_UBUNTU_SECURITY_URL=
ARG SERVICEGEN_APT_UBUNTU_PORTS_URL=
ARG SERVICEGEN_GITHUB_RAW_URL=
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN if [ -n "$SERVICEGEN_APT_UBUNTU_ARCHIVE_URL$SERVICEGEN_APT_UBUNTU_SECURITY_URL$SERVICEGEN_APT_UBUNTU_PORTS_URL" ]; then \
      find /etc/apt -type f \( -name '*.list' -o -name '*.sources' \) -exec sed -i \
        -e "s|http://archive.ubuntu.com/ubuntu|$SERVICEGEN_APT_UBUNTU_ARCHIVE_URL|g" \
        -e "s|http://security.ubuntu.com/ubuntu|$SERVICEGEN_APT_UBUNTU_SECURITY_URL|g" \
        -e "s|http://ports.ubuntu.com/ubuntu-ports|$SERVICEGEN_APT_UBUNTU_PORTS_URL|g" {} +; \
    fi
ENV SERVICEGEN_GITHUB_RAW_URL=${SERVICEGEN_GITHUB_RAW_URL}

COPY docker/cppboost-packages-ubuntu-24.04.txt /tmp/cppboost-packages.txt
RUN rm -f /etc/apt/apt.conf.d/docker-clean
RUN --mount=type=cache,id=servicegen-apt-lists-${TARGETARCH},target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,id=servicegen-apt-cache-${TARGETARCH},target=/var/cache/apt,sharing=locked \
    apt-get update \
    && xargs apt-get install --yes --no-install-recommends \
       ca-certificates locales python3-pip \
       < /tmp/cppboost-packages.txt \
    && locale-gen en_US.UTF-8 \
    && rm -f /tmp/cppboost-packages.txt

COPY --from=servicelib-source / /tmp/servicelib-source
RUN set -eu; \
    source_dir=/tmp/servicelib-source; \
    archive=$(find "$source_dir" -mindepth 1 -maxdepth 1 -type f \( -name context -o -name '*.tar' -o -name '*.tar.gz' -o -name '*.tgz' -o -name '*.tar.xz' \) -print -quit); \
    if [ -n "$archive" ]; then \
      mkdir -p /tmp/servicelib-archive; \
      tar -xf "$archive" -C /tmp/servicelib-archive; \
      source_dir=/tmp/servicelib-archive; \
    fi; \
    manifest="$source_dir/CMakeLists.txt"; \
    if [ ! -f "$manifest" ]; then manifest=$(find "$source_dir" -mindepth 2 -maxdepth 2 -type f -name CMakeLists.txt -print -quit); fi; \
    if [ -z "$manifest" ]; then echo "cppboostservicelib source context has no CMakeLists.txt" >&2; exit 1; fi; \
    source_dir=${manifest%/CMakeLists.txt}; \
    if [ -z "$source_dir" ] || [ "$source_dir" = "/" ]; then echo "unsafe cppboostservicelib source directory" >&2; exit 1; fi; \
    mkdir -p /opt/servicelib; \
    cp -a "$source_dir/." /opt/servicelib/; \
    rm -rf /tmp/servicelib-source
WORKDIR /workspace

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV CPPBOOSTSERVICELIB_SOURCE_DIR=/opt/servicelib
ENV SERVICELIB_SOURCE_DIR=/opt/servicelib

FROM development AS runtime-builder

ARG CPPBOOSTSERVICELIB_PROFILING=OFF
ARG CPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS=OFF
ARG SERVICEGEN_RUNTIME_STRIP=ON
ARG SERVICEGEN_EXAMPLE_PROFILE=function-call
COPY . /workspace
RUN --mount=type=cache,id=cppboostexample-runtime-build-${TARGETARCH}-${SERVICEGEN_EXAMPLE_PROFILE},target=/workspace/build,sharing=locked \
    --mount=type=cache,id=cppboostexample-runtime-ccache-${TARGETARCH},target=/ccache \
    --mount=type=cache,id=servicegen-grpc-v1.71.0-asio-grpc-v3.5.0-sources-${TARGETARCH},target=/var/cache/servicegen-cpp-sources,sharing=locked \
    --mount=type=bind,from=grpc-source-context,target=/servicegen-grpc-source,ro \
    --mount=type=bind,from=asio-grpc-source-context,target=/servicegen-asio-grpc-source,ro \
    grpc_source_arg="" \
    && asio_grpc_source_arg="" \
    && if [ -f /var/cache/servicegen-cpp-sources/grpc-src/include/grpc/grpc.h ]; then \
         grpc_source_arg="-DFETCHCONTENT_SOURCE_DIR_GRPC=/var/cache/servicegen-cpp-sources/grpc-src"; \
       elif [ -f /workspace/build/_deps/grpc-src/include/grpc/grpc.h ]; then \
         grpc_source_arg="-DFETCHCONTENT_SOURCE_DIR_GRPC=/workspace/build/_deps/grpc-src"; \
       fi \
    && if [ -f /var/cache/servicegen-cpp-sources/asio-grpc-src/src/agrpc/asio_grpc.hpp ]; then \
         asio_grpc_source_arg="-DFETCHCONTENT_SOURCE_DIR_ASIO-GRPC=/var/cache/servicegen-cpp-sources/asio-grpc-src"; \
       elif [ -f /workspace/build/_deps/asio-grpc-src/src/agrpc/asio_grpc.hpp ]; then \
         asio_grpc_source_arg="-DFETCHCONTENT_SOURCE_DIR_ASIO-GRPC=/workspace/build/_deps/asio-grpc-src"; \
       fi \
    && if [ -f /servicegen-grpc-source/include/grpc/grpc.h ]; then \
         grpc_source_arg="-DFETCHCONTENT_SOURCE_DIR_GRPC=/servicegen-grpc-source"; \
       fi \
    && if [ -f /servicegen-asio-grpc-source/src/agrpc/asio_grpc.hpp ]; then \
         asio_grpc_source_arg="-DFETCHCONTENT_SOURCE_DIR_ASIO-GRPC=/servicegen-asio-grpc-source"; \
       fi \
    && CCACHE_DIR=/ccache ./scripts/run_with_progress.generated.sh "Release configure" cmake --preset docker-release \
      -DSERVICEGEN_FETCH_CPP_DEPENDENCIES=OFF \
      -DFETCHCONTENT_UPDATES_DISCONNECTED=ON \
      -DCPPBOOSTSERVICELIB_PROFILING="${CPPBOOSTSERVICELIB_PROFILING}" \
      -DCPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS="${CPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS}" \
      ${grpc_source_arg} ${asio_grpc_source_arg} \
    && if [ ! -f /var/cache/servicegen-cpp-sources/grpc-src/include/grpc/grpc.h ]; then \
         grpc_source=/workspace/build/_deps/grpc-src; \
         if [ -f /servicegen-grpc-source/include/grpc/grpc.h ]; then grpc_source=/servicegen-grpc-source; fi; \
         grpc_cache_tmp="/var/cache/servicegen-cpp-sources/.grpc-src.$$"; \
         rm -rf "${grpc_cache_tmp}"; \
         cp -a "${grpc_source}" "${grpc_cache_tmp}"; \
         mv "${grpc_cache_tmp}" /var/cache/servicegen-cpp-sources/grpc-src; \
       fi \
    && if [ ! -f /var/cache/servicegen-cpp-sources/asio-grpc-src/src/agrpc/asio_grpc.hpp ]; then \
         asio_grpc_source=/workspace/build/_deps/asio-grpc-src; \
         if [ -f /servicegen-asio-grpc-source/src/agrpc/asio_grpc.hpp ]; then asio_grpc_source=/servicegen-asio-grpc-source; fi; \
         asio_grpc_cache_tmp="/var/cache/servicegen-cpp-sources/.asio-grpc-src.$$"; \
         rm -rf "${asio_grpc_cache_tmp}"; \
         cp -a "${asio_grpc_source}" "${asio_grpc_cache_tmp}"; \
         mv "${asio_grpc_cache_tmp}" /var/cache/servicegen-cpp-sources/asio-grpc-src; \
       fi \
    && ./scripts/run_with_progress.generated.sh "Release build" cmake --build --preset docker-release \
      --target example_analytics_service example_inventory_service example_order_service --parallel \
    && mkdir -p /opt/service-bin /opt/runtime-libs \
    && mkdir -p /opt/runtime-libs/analyticsservice \
    && cp /workspace/build/analyticsservice/example_analytics_service /opt/service-bin/example_analytics_service \
    && mkdir -p /opt/runtime-libs/inventoryservice \
    && cp /workspace/build/inventoryservice/example_inventory_service /opt/service-bin/example_inventory_service \
    && mkdir -p /opt/runtime-libs/orderservice \
    && cp /workspace/build/orderservice/example_order_service /opt/service-bin/example_order_service \
    && if [ "${SERVICEGEN_RUNTIME_STRIP}" = "ON" ]; then \
         strip --strip-unneeded /opt/service-bin/*; \
       fi \
    && ldd /opt/service-bin/example_analytics_service \
       | awk '/=> \/.*\// {print $3} /\/ld-linux/ {print $1}' \
       | sort -u | while read -r library; do \
         cp -L "$library" "/opt/runtime-libs/analyticsservice/$(basename "$library")"; \
       done \
    && ldd /opt/service-bin/example_inventory_service \
       | awk '/=> \/.*\// {print $3} /\/ld-linux/ {print $1}' \
       | sort -u | while read -r library; do \
         cp -L "$library" "/opt/runtime-libs/inventoryservice/$(basename "$library")"; \
       done \
    && ldd /opt/service-bin/example_order_service \
       | awk '/=> \/.*\// {print $3} /\/ld-linux/ {print $1}' \
       | sort -u | while read -r library; do \
         cp -L "$library" "/opt/runtime-libs/orderservice/$(basename "$library")"; \
       done \
    && true

FROM ubuntu:24.04 AS runtime-base

ARG CPPBOOSTSERVICELIB_PROFILING=OFF
ARG CPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS=OFF
ARG DEBIAN_FRONTEND=noninteractive
ARG SERVICEGEN_APT_UBUNTU_ARCHIVE_URL=
ARG SERVICEGEN_APT_UBUNTU_SECURITY_URL=
ARG SERVICEGEN_APT_UBUNTU_PORTS_URL=
RUN if [ -n "$SERVICEGEN_APT_UBUNTU_ARCHIVE_URL$SERVICEGEN_APT_UBUNTU_SECURITY_URL$SERVICEGEN_APT_UBUNTU_PORTS_URL" ]; then \
      find /etc/apt -type f \( -name '*.list' -o -name '*.sources' \) -exec sed -i \
        -e "s|http://archive.ubuntu.com/ubuntu|$SERVICEGEN_APT_UBUNTU_ARCHIVE_URL|g" \
        -e "s|http://security.ubuntu.com/ubuntu|$SERVICEGEN_APT_UBUNTU_SECURITY_URL|g" \
        -e "s|http://ports.ubuntu.com/ubuntu-ports|$SERVICEGEN_APT_UBUNTU_PORTS_URL|g" {} +; \
    fi
RUN apt-get update \
    && apt-get install --yes --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*
ENV LD_LIBRARY_PATH=/usr/local/lib/servicegen
LABEL org.gorundebug.build-type="Release" \
      org.gorundebug.cppboostservicelib.profiling="${CPPBOOSTSERVICELIB_PROFILING}" \
      org.gorundebug.cppboostservicelib.coroutine-diagnostics="${CPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS}"
WORKDIR /app

FROM runtime-base AS runtime-analyticsservice
COPY --from=runtime-builder /opt/runtime-libs/analyticsservice /usr/local/lib/servicegen
COPY --from=runtime-builder /opt/service-bin/example_analytics_service /usr/local/bin/example_analytics_service
COPY analyticsservice/config/*.yaml /app/config/
ENTRYPOINT ["/usr/local/bin/example_analytics_service"]

FROM runtime-base AS runtime-inventoryservice
COPY --from=runtime-builder /opt/runtime-libs/inventoryservice /usr/local/lib/servicegen
COPY --from=runtime-builder /opt/service-bin/example_inventory_service /usr/local/bin/example_inventory_service
COPY inventoryservice/config/*.yaml /app/config/
ENTRYPOINT ["/usr/local/bin/example_inventory_service"]

FROM runtime-base AS runtime-orderservice
COPY --from=runtime-builder /opt/runtime-libs/orderservice /usr/local/lib/servicegen
COPY --from=runtime-builder /opt/service-bin/example_order_service /usr/local/bin/example_order_service
COPY orderservice/config/*.yaml /app/config/
ENTRYPOINT ["/usr/local/bin/example_order_service"]