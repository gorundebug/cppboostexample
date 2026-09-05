ARG DEPENDENCY_DOCKER_REGISTRY=docker.io
FROM servicelib-source AS servicelib-source
FROM module-model_cpp AS module-model_cpp

FROM ${DEPENDENCY_DOCKER_REGISTRY}/library/ubuntu:24.04 AS development

ARG TARGETARCH
ARG DEPENDENCY_APT_UBUNTU_ARCHIVE_URL=
ARG DEPENDENCY_APT_UBUNTU_SECURITY_URL=
ARG DEPENDENCY_APT_UBUNTU_PORTS_URL=
ARG DEPENDENCY_GITHUB_RAW_URL=
ARG DEPENDENCY_CONAN_REMOTE_URL=
ARG DEPENDENCY_CONAN_UPLOAD_URL=
ARG DEPENDENCY_CONAN_PUBLISH=0
ARG PIP_INDEX_URL=https://pypi.org/simple
ARG PIP_TRUSTED_HOST=
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN if [ -n "$DEPENDENCY_APT_UBUNTU_ARCHIVE_URL$DEPENDENCY_APT_UBUNTU_SECURITY_URL$DEPENDENCY_APT_UBUNTU_PORTS_URL" ]; then \
      find /etc/apt -type f \( -name '*.list' -o -name '*.sources' \) -exec sed -i \
        -e "s|http://archive.ubuntu.com/ubuntu|$DEPENDENCY_APT_UBUNTU_ARCHIVE_URL|g" \
        -e "s|http://security.ubuntu.com/ubuntu|$DEPENDENCY_APT_UBUNTU_SECURITY_URL|g" \
        -e "s|http://ports.ubuntu.com/ubuntu-ports|$DEPENDENCY_APT_UBUNTU_PORTS_URL|g" {} +; \
    fi
ENV DEPENDENCY_GITHUB_RAW_URL=${DEPENDENCY_GITHUB_RAW_URL}
ENV DEPENDENCY_CONAN_REMOTE_URL=${DEPENDENCY_CONAN_REMOTE_URL}
ENV DEPENDENCY_CONAN_UPLOAD_URL=${DEPENDENCY_CONAN_UPLOAD_URL}
ENV DEPENDENCY_CONAN_PUBLISH=${DEPENDENCY_CONAN_PUBLISH}
COPY dependency-download-mirrors.generated.env /etc/servicegen/dependency-download-mirrors.generated.env
COPY dependency-download-mirrors.env /etc/servicegen/dependency-download-mirrors.env
COPY dependency-download-env.generated.sh /usr/local/bin/servicegen-download-env
SHELL ["/usr/local/bin/servicegen-download-env", "/bin/sh", "-c"]

COPY docker/cppboost-packages.txt /tmp/cppboost-packages.txt
RUN rm -f /etc/apt/apt.conf.d/docker-clean
RUN --mount=type=cache,id=servicegen-apt-lists-${TARGETARCH},target=/var/lib/apt/lists,sharing=locked \
    --mount=type=cache,id=servicegen-apt-cache-${TARGETARCH},target=/var/cache/apt,sharing=locked \
    apt-get -o Acquire::http::Timeout=30 -o Acquire::https::Timeout=30 -o Acquire::Retries=2 update \
    && xargs apt-get -o Acquire::http::Timeout=30 -o Acquire::https::Timeout=30 -o Acquire::Retries=2 install --yes --no-install-recommends \
       ca-certificates locales python3-pip \
       < /tmp/cppboost-packages.txt \
    && locale-gen en_US.UTF-8 \
    && rm -f /tmp/cppboost-packages.txt

RUN python3 -m venv /opt/conan \
    && PIP_TRUSTED_HOST="$PIP_TRUSTED_HOST" \
       /opt/conan/bin/pip install --no-cache-dir --index-url "$PIP_INDEX_URL" \
       conan==2.31.1
ENV PATH=/opt/conan/bin:$PATH
ENV CONAN_HOME=/conan

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
    cp -R "$source_dir/." /opt/servicelib/; \
    rm -rf /tmp/servicelib-source
WORKDIR /workspace
COPY --from=module-model_cpp / /workspace/modules/model_cpp

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV SERVICELIB_SOURCE_DIR=/opt/servicelib

# The ordinary build/test/sanitizer image owns an immutable copy of the
# service sources.  Development and debugger commands may overlay this path
# with the explicitly read-only source mount from the dev compose file.
FROM development AS source-builder
COPY . /workspace/source
WORKDIR /workspace/source

FROM development AS debug-builder

COPY . /workspace
RUN --mount=type=cache,id=cppboostexample-debug-build-${TARGETARCH},target=/workspace/build,sharing=locked \
    --mount=type=cache,id=cppboostexample-debug-ccache-${TARGETARCH},target=/ccache \
    --mount=type=cache,id=servicegen-conan2-${TARGETARCH},target=/conan,sharing=locked \
    --mount=type=secret,id=dependency_conan_credential \
    ./scripts/run_with_progress.generated.sh "Conan Debug install" \
      ./scripts/conan-install.generated.sh Debug /workspace/build/conan-debug \
    && conan_toolchain="$(cat /workspace/build/conan-debug/toolchain.path)" \
    && CCACHE_DIR=/ccache ./scripts/run_with_progress.generated.sh "Debug configure" cmake --preset docker-debug \
      --fresh \
      -DCMAKE_TOOLCHAIN_FILE="${conan_toolchain}" \
      -DFETCH_CPP_DEPENDENCIES=OFF \
    && ./scripts/run_with_progress.generated.sh "Debug build" cmake --build --preset docker-debug --parallel

FROM debug-builder AS test-builder
RUN --mount=type=cache,id=cppboostexample-debug-build-${TARGETARCH},target=/workspace/build,sharing=locked \
    --mount=type=cache,id=servicegen-conan2-${TARGETARCH},target=/conan,sharing=locked \
    ./scripts/run_with_progress.generated.sh "Debug test" \
      ctest --test-dir /workspace/build --output-on-failure --no-tests=error

FROM development AS runtime-builder

ARG CPPBOOSTSERVICELIB_PROFILING=OFF
ARG CPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS=OFF
ARG RUNTIME_STRIP=ON
ARG EXAMPLE_PROFILE=function-call
COPY . /workspace
RUN --mount=type=cache,id=cppboostexample-runtime-build-${TARGETARCH}-${EXAMPLE_PROFILE},target=/workspace/build,sharing=locked \
    --mount=type=cache,id=cppboostexample-runtime-ccache-${TARGETARCH},target=/ccache \
    --mount=type=cache,id=servicegen-conan2-${TARGETARCH},target=/conan,sharing=locked \
    --mount=type=secret,id=dependency_conan_credential \
    CPPBOOSTSERVICELIB_BUILD_TESTS=False \
      ./scripts/run_with_progress.generated.sh "Conan Release install" \
      ./scripts/conan-install.generated.sh Release /workspace/build/conan-release \
    && conan_toolchain="$(cat /workspace/build/conan-release/toolchain.path)" \
    && CCACHE_DIR=/ccache ./scripts/run_with_progress.generated.sh "Release configure" cmake --preset docker-release \
      --fresh \
      -DCMAKE_TOOLCHAIN_FILE="${conan_toolchain}" \
      -DBUILD_TESTING=OFF \
      -DFETCH_CPP_DEPENDENCIES=OFF \
      -DCPPBOOSTSERVICELIB_PROFILING="${CPPBOOSTSERVICELIB_PROFILING}" \
      -DCPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS="${CPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS}" \
    && ./scripts/run_with_progress.generated.sh "Release build" cmake --build --preset docker-release \
      --target example_analytics_service --parallel \
    && mkdir -p /opt/service-bin /opt/runtime-libs \
    && mkdir -p /opt/runtime-libs/analyticsservice \
    && cp /workspace/build/example_analytics_service /opt/service-bin/example_analytics_service \
    && if [ "${RUNTIME_STRIP}" = "ON" ]; then \
         strip --strip-unneeded /opt/service-bin/*; \
       fi \
    && ldd /opt/service-bin/example_analytics_service \
       | awk '/=> \/.*\// {print $3} /\/ld-linux/ {print $1}' \
       | sort -u | while read -r library; do \
         cp -L "$library" "/opt/runtime-libs/analyticsservice/$(basename "$library")"; \
       done \
    && true

FROM ${DEPENDENCY_DOCKER_REGISTRY}/library/ubuntu:24.04 AS runtime-base

ARG CPPBOOSTSERVICELIB_PROFILING=OFF
ARG CPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS=OFF
ARG DEBIAN_FRONTEND=noninteractive
ARG DEPENDENCY_APT_UBUNTU_ARCHIVE_URL=
ARG DEPENDENCY_APT_UBUNTU_SECURITY_URL=
ARG DEPENDENCY_APT_UBUNTU_PORTS_URL=
COPY dependency-download-mirrors.generated.env /etc/servicegen/dependency-download-mirrors.generated.env
COPY dependency-download-mirrors.env /etc/servicegen/dependency-download-mirrors.env
COPY dependency-download-env.generated.sh /usr/local/bin/servicegen-download-env
SHELL ["/usr/local/bin/servicegen-download-env", "/bin/sh", "-c"]
RUN if [ -n "$DEPENDENCY_APT_UBUNTU_ARCHIVE_URL$DEPENDENCY_APT_UBUNTU_SECURITY_URL$DEPENDENCY_APT_UBUNTU_PORTS_URL" ]; then \
      find /etc/apt -type f \( -name '*.list' -o -name '*.sources' \) -exec sed -i \
        -e "s|http://archive.ubuntu.com/ubuntu|$DEPENDENCY_APT_UBUNTU_ARCHIVE_URL|g" \
        -e "s|http://security.ubuntu.com/ubuntu|$DEPENDENCY_APT_UBUNTU_SECURITY_URL|g" \
        -e "s|http://ports.ubuntu.com/ubuntu-ports|$DEPENDENCY_APT_UBUNTU_PORTS_URL|g" {} +; \
    fi
RUN apt-get -o Acquire::http::Timeout=30 -o Acquire::https::Timeout=30 -o Acquire::Retries=2 update \
    && apt-get -o Acquire::http::Timeout=30 -o Acquire::https::Timeout=30 -o Acquire::Retries=2 install --yes --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*
ENV LD_LIBRARY_PATH=/usr/local/lib/servicegen
LABEL org.gorundebug.build-type="Release" \
      org.gorundebug.cppboostservicelib.profiling="${CPPBOOSTSERVICELIB_PROFILING}" \
      org.gorundebug.cppboostservicelib.coroutine-diagnostics="${CPPBOOSTSERVICELIB_COROUTINE_DIAGNOSTICS}"
WORKDIR /app

FROM runtime-base AS runtime-analyticsservice
COPY --from=runtime-builder /opt/runtime-libs/analyticsservice /usr/local/lib/servicegen
COPY --from=runtime-builder /opt/service-bin/example_analytics_service /usr/local/bin/example_analytics_service
COPY config/*.yaml /app/config/
ENTRYPOINT ["/usr/local/bin/example_analytics_service"]