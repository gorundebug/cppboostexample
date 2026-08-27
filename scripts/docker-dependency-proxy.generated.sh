#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${SERVICEGEN_REAL_DOCKER:-}" ]]; then
  echo "SERVICEGEN_REAL_DOCKER is not set" >&2
  exit 2
fi

if [[ -z "${SERVICEGEN_DEPENDENCY_PROXY_DIR:-}" ]]; then
  exec "$SERVICEGEN_REAL_DOCKER" "$@"
fi

docker_host="${SERVICEGEN_DEPENDENCY_PROXY_DOCKER_HOST:-${SERVICEGEN_NEXUS_DOCKER_HOST:-host.docker.internal}}"
nexus_port="${SERVICEGEN_NEXUS_PORT:-18081}"
git_mirror_port="${SERVICEGEN_GIT_MIRROR_PORT:-18084}"
repository_base="http://${docker_host}:${nexus_port}/repository"
git_mirror_base="http://${docker_host}:${git_mirror_port}/cgi-bin/git"

# This is the single container-side dependency routing contract. Dockerfiles
# opt in declaratively by declaring an ARG with one of these names; direct
# docker builds receive every declared value automatically.
export GOPROXY="${repository_base}/go-proxy/"
export GOSUMDB=off
export NPM_CONFIG_REGISTRY="${repository_base}/npm-proxy/"
export PIP_INDEX_URL="${repository_base}/pypi-proxy/simple"
export PIP_TRUSTED_HOST="$docker_host"
export UV_INDEX_URL="${repository_base}/pypi-proxy/simple"
export CARGO_REGISTRIES_CRATES_IO_INDEX="sparse+${repository_base}/cargo-proxy/"
export SERVICEGEN_MAVEN_CENTRAL_URL="${repository_base}/maven-central"
export SERVICEGEN_CONAN_REMOTE_URL="${repository_base}/conan-proxy"
export SERVICEGEN_GITHUB_RAW_URL="${repository_base}/github-raw"
export SERVICEGEN_GITLAB_RAW_URL="${repository_base}/gitlab-raw"
export SERVICEGEN_APT_UBUNTU_ARCHIVE_URL="${repository_base}/apt-ubuntu-archive"
export SERVICEGEN_APT_UBUNTU_SECURITY_URL="${repository_base}/apt-ubuntu-security"
export SERVICEGEN_APT_UBUNTU_PORTS_URL="${repository_base}/apt-ubuntu-ports"
export SERVICEGEN_APT_DEBIAN_URL="${repository_base}/apt-debian"
export SERVICEGEN_APT_DEBIAN_SECURITY_URL="${repository_base}/apt-debian-security"
export SERVICEGEN_GIT_MIRROR_URL="$git_mirror_base"
export GIT_CONFIG_COUNT=2
export GIT_CONFIG_KEY_0="url.${git_mirror_base}/github.com/.insteadOf"
export GIT_CONFIG_VALUE_0=https://github.com/
export GIT_CONFIG_KEY_1="url.${git_mirror_base}/gitlab.com/.insteadOf"
export GIT_CONFIG_VALUE_1=https://gitlab.com/

proxy_build_variables=(
  GOPROXY GOSUMDB NPM_CONFIG_REGISTRY PIP_INDEX_URL PIP_TRUSTED_HOST
  UV_INDEX_URL CARGO_REGISTRIES_CRATES_IO_INDEX
  SERVICEGEN_MAVEN_CENTRAL_URL SERVICEGEN_CONAN_REMOTE_URL
  SERVICEGEN_GITHUB_RAW_URL SERVICEGEN_GITLAB_RAW_URL
  SERVICEGEN_APT_UBUNTU_ARCHIVE_URL SERVICEGEN_APT_UBUNTU_SECURITY_URL
  SERVICEGEN_APT_UBUNTU_PORTS_URL SERVICEGEN_APT_DEBIAN_URL
  SERVICEGEN_APT_DEBIAN_SECURITY_URL SERVICEGEN_GIT_MIRROR_URL
)

proxy_build() {
  local frontend="$1"
  shift
  local -a original=("$@") injected=()
  local dockerfile=Dockerfile index=0 argument
  while (( index < ${#original[@]} )); do
    argument="${original[$index]}"
    case "$argument" in
      -f|--file)
        ((index += 1))
        dockerfile="${original[$index]}"
        ;;
      --file=*) dockerfile="${argument#*=}" ;;
    esac
    ((index += 1))
  done

  injected+=(--add-host "host.docker.internal:host-gateway")
  local name
  for name in "${proxy_build_variables[@]}"; do
    if [[ ! -f "$dockerfile" ]] || grep -Eq "^[[:space:]]*ARG[[:space:]]+${name}([[:space:]=]|$)" "$dockerfile"; then
      injected+=(--build-arg "${name}=${!name}")
    fi
  done
  if [[ "$frontend" == buildx ]]; then
    exec "$SERVICEGEN_REAL_DOCKER" buildx build "${injected[@]}" "${original[@]}"
  fi
  exec "$SERVICEGEN_REAL_DOCKER" build "${injected[@]}" "${original[@]}"
}

if [[ "${1:-}" == build ]]; then
  shift
  proxy_build build "$@"
fi

if [[ "${1:-}" == buildx && "${2:-}" == build ]]; then
  shift 2
  proxy_build buildx "$@"
fi

if [[ "${1:-}" == run ]]; then
  shift
  exec "$SERVICEGEN_REAL_DOCKER" run \
    --add-host "host.docker.internal:host-gateway" "$@"
fi

exec "$SERVICEGEN_REAL_DOCKER" "$@"