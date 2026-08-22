#!/usr/bin/env bash
set -euo pipefail

if (($# != 2)); then
  echo "usage: $0 <service-directory> <output-directory>" >&2
  exit 2
fi

service_dir="${1%/}"
output_dir="${2%/}"
service_name="$(basename "${service_dir}")"

if [[ ! -f "${service_dir}/CMakeLists.txt" ]]; then
  echo "C++ service directory does not contain CMakeLists.txt: ${service_dir}" >&2
  exit 1
fi
for file in Makefile make.generated.mk docker-compose.generated.yml \
  docker-compose.cmake.generated.yml; do
  if [[ ! -f "${service_dir}/${file}" ]]; then
    echo "C++ service publishing file is missing: ${service_dir}/${file}" >&2
    exit 1
  fi
done
if [[ -e "${output_dir}" && -n "$(find "${output_dir}" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
  echo "output directory must be empty: ${output_dir}" >&2
  exit 1
fi

mkdir -p "${output_dir}"
cp -R "${service_dir}/." "${output_dir}/"

# A published service is self-contained: retain the exact generated contract
# modules it was compiled against instead of requiring sibling repositories to
# exist or be publicly reachable. The standalone CMake project prefers this
# directory and retains its explicit external/fetch fallbacks.
module_dirs=("inventory_service_api" "model" "order_service_api" )
mkdir -p "${output_dir}/modules"
for module_dir in "${module_dirs[@]}"; do
  if [[ ! -f "${module_dir}/CMakeLists.txt" ]]; then
    echo "C++ contract module is missing: ${module_dir}" >&2
    exit 1
  fi
  cp -R "${module_dir}" "${output_dir}/modules/${module_dir}"
done

cp CMakePresets.json Dockerfile.cmake docker-compose.cmake.generated.yml \
  .clang-format .clang-tidy .dockerignore "${output_dir}/"

mkdir -p "${output_dir}/docker" "${output_dir}/scripts"
cp -R docker/. "${output_dir}/docker/"
cp scripts/cmake-docker.generated.sh scripts/build.generated.sh scripts/test.generated.sh \
  scripts/lint.generated.sh scripts/format.generated.sh \
  scripts/configure-git-auth.generated.sh \
  scripts/run_with_progress.generated.sh "${output_dir}/scripts/"

# Generated source names make replacement explicit inside the
# workspace; a published repository receives conventional Compose filenames.
cp "${service_dir}/docker-compose.generated.yml" \
  "${output_dir}/docker-compose.yml"
cp "${service_dir}/docker-compose.cmake.generated.yml" \
  "${output_dir}/docker-compose.cmake.yml"
rm -f "${output_dir}/docker-compose.generated.yml" \
  "${output_dir}/docker-compose.cmake.generated.yml"

# The source workspace deliberately marks generated Compose files in their
# names. A published service uses conventional names, so every copied command
# must follow the rename as well. Keep this transformation inside the package;
# the generated multi-service workspace remains unchanged.
while IFS= read -r packaged_file; do
  if grep -q 'docker-compose\.cmake\.generated\.yml' "${packaged_file}"; then
    sed -i.bak \
      's/docker-compose\.cmake\.generated\.yml/docker-compose.cmake.yml/g' \
      "${packaged_file}"
    rm -f "${packaged_file}.bak"
  fi
done < <(find "${output_dir}" -type f \
  \( -name 'make.generated.mk' -o -name '*.generated.sh' \) -print)

echo "Packaged standalone C++ service ${service_name} in ${output_dir}"