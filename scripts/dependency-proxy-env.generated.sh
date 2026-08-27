#!/usr/bin/env bash

# This file is sourced by generated Docker/Conan entry points. Keep direct
# script execution equivalent to the corresponding Make target: the proxy is
# strictly opt-in and no project-local proxy is enabled implicitly.
if [[ -n "${SERVICEGEN_DEPENDENCY_PROXY_DIR:-}" ]]; then
  servicegen_proxy_docker_host="${SERVICEGEN_DEPENDENCY_PROXY_DOCKER_HOST:-host.docker.internal}"
  servicegen_proxy_port="${SERVICEGEN_DEPENDENCY_PROXY_PORT:-${SERVICEGEN_NEXUS_PORT:-18081}}"
  servicegen_proxy_base="http://${servicegen_proxy_docker_host}:${servicegen_proxy_port}/repository"

  export SERVICEGEN_CONAN_HOME="${SERVICEGEN_DEPENDENCY_PROXY_DIR}/conan2"
  export SERVICEGEN_GITHUB_RAW_URL="${servicegen_proxy_base}/github-raw"
  export SERVICEGEN_CONAN_REMOTE_URL="${servicegen_proxy_base}/conan-proxy"
  export PIP_INDEX_URL="${servicegen_proxy_base}/pypi-proxy/simple"
  export PIP_TRUSTED_HOST="${servicegen_proxy_docker_host}"
  export SERVICEGEN_APT_UBUNTU_ARCHIVE_URL="${servicegen_proxy_base}/apt-ubuntu-archive"
  export SERVICEGEN_APT_UBUNTU_SECURITY_URL="${servicegen_proxy_base}/apt-ubuntu-security"
  export SERVICEGEN_APT_UBUNTU_PORTS_URL="${servicegen_proxy_base}/apt-ubuntu-ports"
  export CPPBOOSTSERVICELIB_SOURCE_CONTEXT="${CPPBOOSTSERVICELIB_SOURCE_CONTEXT:-${servicegen_proxy_base}/github-raw/gorundebug/cppboostservicelib/archive/refs/tags/v0.2.17.tar.gz}"
fi