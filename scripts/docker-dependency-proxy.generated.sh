#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${DEPENDENCY_REAL_DOCKER:-}" ]]; then
  echo "DEPENDENCY_REAL_DOCKER is not set" >&2
  exit 2
fi

if [[ -z "${DEPENDENCY_PROXY_DIR:-}" ]]; then
  exec "$DEPENDENCY_REAL_DOCKER" "$@"
fi

docker_host="${DEPENDENCY_PROXY_DOCKER_HOST:-host.docker.internal}"
nexus_port="${DEPENDENCY_PROXY_PORT:-18081}"
git_mirror_port="${DEPENDENCY_GIT_MIRROR_PORT:-18084}"
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
export DEPENDENCY_MAVEN_CENTRAL_URL="${repository_base}/maven-central"
export DEPENDENCY_CONAN_REMOTE_URL="${repository_base}/conan-proxy"
export DEPENDENCY_GITHUB_RAW_URL="${repository_base}/github-raw"
export DEPENDENCY_GITLAB_RAW_URL="${repository_base}/gitlab-raw"
export DEPENDENCY_APT_UBUNTU_ARCHIVE_URL="${repository_base}/apt-ubuntu-archive"
export DEPENDENCY_APT_UBUNTU_SECURITY_URL="${repository_base}/apt-ubuntu-security"
export DEPENDENCY_APT_UBUNTU_PORTS_URL="${repository_base}/apt-ubuntu-ports"
export DEPENDENCY_APT_DEBIAN_URL="${repository_base}/apt-debian"
export DEPENDENCY_APT_DEBIAN_SECURITY_URL="${repository_base}/apt-debian-security"
export DEPENDENCY_GIT_MIRROR_URL="$git_mirror_base"
export GIT_CONFIG_COUNT=2
export GIT_CONFIG_KEY_0="url.${git_mirror_base}/github.com/.insteadOf"
export GIT_CONFIG_VALUE_0=https://github.com/
export GIT_CONFIG_KEY_1="url.${git_mirror_base}/gitlab.com/.insteadOf"
export GIT_CONFIG_VALUE_1=https://gitlab.com/

proxy_build_variables=(
  GOPROXY GOSUMDB NPM_CONFIG_REGISTRY PIP_INDEX_URL PIP_TRUSTED_HOST
  UV_INDEX_URL CARGO_REGISTRIES_CRATES_IO_INDEX
  DEPENDENCY_MAVEN_CENTRAL_URL DEPENDENCY_CONAN_REMOTE_URL
  DEPENDENCY_GITHUB_RAW_URL DEPENDENCY_GITLAB_RAW_URL
  DEPENDENCY_APT_UBUNTU_ARCHIVE_URL DEPENDENCY_APT_UBUNTU_SECURITY_URL
  DEPENDENCY_APT_UBUNTU_PORTS_URL DEPENDENCY_APT_DEBIAN_URL
  DEPENDENCY_APT_DEBIAN_SECURITY_URL DEPENDENCY_GIT_MIRROR_URL
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
    exec "$DEPENDENCY_REAL_DOCKER" buildx build "${injected[@]}" "${original[@]}"
  fi
  exec "$DEPENDENCY_REAL_DOCKER" build "${injected[@]}" "${original[@]}"
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
  exec "$DEPENDENCY_REAL_DOCKER" run \
    --add-host "host.docker.internal:host-gateway" "$@"
fi

exec "$DEPENDENCY_REAL_DOCKER" "$@"