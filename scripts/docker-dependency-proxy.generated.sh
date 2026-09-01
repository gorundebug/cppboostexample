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
registry_host="${DEPENDENCY_PROXY_HOST:-localhost}"
nexus_port="${DEPENDENCY_PROXY_PORT:-18081}"
registry_port="${DEPENDENCY_PROXY_DOCKER_PORT:-18083}"
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
# Base images are resolved by the host Docker daemon/BuildKit, not by a RUN
# command inside the build container. Use the host-published registry endpoint;
# container-side package downloads continue to use docker_host above.
export DEPENDENCY_DOCKER_REGISTRY="${registry_host}:${registry_port}"
export CARGO_REGISTRIES_CRATES_IO_INDEX="sparse+${repository_base}/cargo-proxy/"
export DEPENDENCY_MAVEN_CENTRAL_URL="${repository_base}/maven-central"
export DEPENDENCY_CONAN_REMOTE_URL="${repository_base}/conan-group"
export DEPENDENCY_CONAN_UPLOAD_URL="${repository_base}/conan-hosted"
export DEPENDENCY_CONAN_PUBLISH=1
export DEPENDENCY_CONAN_CREDENTIAL_FILE="${DEPENDENCY_PROXY_DIR%/}/conan.publisher.credential"
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
  DEPENDENCY_DOCKER_REGISTRY
  GOPROXY GOSUMDB NPM_CONFIG_REGISTRY PIP_INDEX_URL PIP_TRUSTED_HOST
  UV_INDEX_URL CARGO_REGISTRIES_CRATES_IO_INDEX
  DEPENDENCY_MAVEN_CENTRAL_URL DEPENDENCY_CONAN_REMOTE_URL
  DEPENDENCY_CONAN_UPLOAD_URL DEPENDENCY_CONAN_PUBLISH
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
  if [[ -s "$DEPENDENCY_CONAN_CREDENTIAL_FILE" ]]; then
    injected+=(--secret "id=dependency_conan_credential,src=$DEPENDENCY_CONAN_CREDENTIAL_FILE")
  fi
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

proxy_image_reference() {
  local image="$1" registry path first
  case "$image" in
    docker.io/*)
      registry="$DEPENDENCY_DOCKER_REGISTRY"
      path="${image#docker.io/}"
      ;;
    ghcr.io/*)
      registry="${registry_host}:${DEPENDENCY_PROXY_GHCR_PORT:-18085}"
      path="${image#ghcr.io/}"
      ;;
    quay.io/*)
      registry="${registry_host}:${DEPENDENCY_PROXY_QUAY_PORT:-18086}"
      path="${image#quay.io/}"
      ;;
    docker.redpanda.com/*)
      registry="${registry_host}:${DEPENDENCY_PROXY_REDPANDA_PORT:-18087}"
      path="${image#docker.redpanda.com/}"
      ;;
    registry.k8s.io/*)
      registry="${registry_host}:${DEPENDENCY_PROXY_KUBERNETES_PORT:-18088}"
      path="${image#registry.k8s.io/}"
      ;;
    localhost/*|localhost:*/*|127.0.0.1/*|127.0.0.1:*/*|host.docker.internal/*|host.docker.internal:*/*)
      printf '%s\n' "$image"
      return
      ;;
    */*)
      first="${image%%/*}"
      if [[ "$first" == *.* || "$first" == *:* ]]; then
        echo "No dependency proxy registry is configured for image '$image'" >&2
        return 1
      fi
      registry="$DEPENDENCY_DOCKER_REGISTRY"
      path="$image"
      ;;
    *)
      registry="$DEPENDENCY_DOCKER_REGISTRY"
      path="library/$image"
      ;;
  esac
  printf '%s/%s\n' "$registry" "$path"
}

proxy_run() {
  local -a original=("$@") arguments=()
  local index=0 argument
  # Proxy mode owns pull policy. Remove a caller-provided policy so Docker can
  # never contact the original registry before the wrapper has routed it.
  while (( index < ${#original[@]} )); do
    argument="${original[$index]}"
    case "$argument" in
      --pull)
        ((index += 2))
        continue
        ;;
      --pull=*)
        ((index += 1))
        continue
        ;;
    esac
    arguments+=("$argument")
    ((index += 1))
  done

  local capture_dir error_output error_pipe tee_pid tee_status
  local status missing_image proxy_image
  capture_dir="$(mktemp -d "${TMPDIR:-/tmp}/dependency-docker-run.XXXXXX")"
  error_output="$capture_dir/stderr"
  error_pipe="$capture_dir/stderr.pipe"
  mkfifo "$error_pipe"
  tee "$error_output" < "$error_pipe" >&2 &
  tee_pid=$!
  set +e
  "$DEPENDENCY_REAL_DOCKER" run --pull=never \
    --add-host "host.docker.internal:host-gateway" "${arguments[@]}" \
    2> "$error_pipe"
  status=$?
  wait "$tee_pid"
  tee_status=$?
  set -e
  rm -f "$error_pipe"
  if [[ "$tee_status" -ne 0 ]]; then
    rm -rf "$capture_dir"
    return "$tee_status"
  fi
  if [[ "$status" -eq 125 ]]; then
    missing_image="$(sed -n 's/^docker: Error response from daemon: No such image: //p' "$error_output" | head -n 1)"
    if [[ -n "$missing_image" ]]; then
      if ! proxy_image="$(proxy_image_reference "$missing_image")"; then
        rm -rf "$capture_dir"
        return "$status"
      fi
      echo "[dependency-proxy] pulling $missing_image through $proxy_image" >&2
      "$DEPENDENCY_REAL_DOCKER" pull "$proxy_image"
      "$DEPENDENCY_REAL_DOCKER" tag "$proxy_image" "$missing_image"
      rm -rf "$capture_dir"
      exec "$DEPENDENCY_REAL_DOCKER" run --pull=never \
        --add-host "host.docker.internal:host-gateway" "${arguments[@]}"
    fi
  fi
  rm -rf "$capture_dir"
  return "$status"
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
  proxy_run "$@"
  exit $?
fi

exec "$DEPENDENCY_REAL_DOCKER" "$@"