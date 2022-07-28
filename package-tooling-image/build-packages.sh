#!/bin/bash

set -euo pipefail

if [ ! -z "${REGISTRY_USERNAME:-}" ] && [ ! -z "${REGISTRY_PASSWORD:-}" ] && [ ! -z "${REGISTRY_SERVER:-}" ]; then
   docker login --username "${REGISTRY_USERNAME}" --password "${REGISTRY_PASSWORD}" "${REGISTRY_SERVER}"
fi

# Start a local docker registry
echo "Stopping and removing any existing local docker registry..."
docker container stop registry && docker container rm -v registry || true
echo "Starting local docker registry..."
docker run -d -p 5001:5000 --name registry mirror.gcr.io/library/registry:2

cd /workspace

# Install needed Carvel binaries for building packages
echo "Downloading carvel binaries..."
package-tools prepare

if [[ "${OPERATIONS}" == *"kbld_replace"* ]]; then
  package-tools kbld-replace \
  "${DEFAULT_IMAGE}" "${NEW_IMAGE}" \
  --kbld-config-file="${KBLD_CONFIG_FILE_PATH}";
fi

if [[ "${OPERATIONS}" == *"package_bundle_generate"* ]]; then
  package-tools package-bundle generate "${PACKAGE_NAME}" \
  --thick="${THICK}" \
  --version="${PACKAGE_VERSION}" \
  --sub-version="${PACKAGE_SUB_VERSION}" \
  --registry="${OCI_REGISTRY}" \
  --local-registry-url="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' registry):5000";
fi

if [[ "${OPERATIONS}" == *"package_bundle_all_generate"* ]]; then
  package-tools package-bundle generate \
  --all \
  --thick="${THICK}" \
  --version="${PACKAGE_VERSION}" \
  --sub-version="${PACKAGE_SUB_VERSION}" \
  --repository="${PACKAGE_REPOSITORY}" \
  --registry="${OCI_REGISTRY}" \
  --local-registry-url="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' registry):5000";
fi

if [[ "${OPERATIONS}" == *"package_bundle_push"* ]]; then
  package-tools package-bundle push "${PACKAGE_NAME}" \
  --version="${PACKAGE_VERSION}" \
  --sub-version=${PACKAGE_SUB_VERSION} \
  --registry="${OCI_REGISTRY}";
fi

if [[ "${OPERATIONS}" == *"package_bundle_all_push"* ]]; then
  package-tools package-bundle push \
  --all \
  --repository="${PACKAGE_REPOSITORY}" \
  --version="${PACKAGE_VERSION}" \
  --sub-version=${PACKAGE_SUB_VERSION} \
  --registry="${OCI_REGISTRY}";
fi

if [[ "${OPERATIONS}" == *"repo_bundle_generate"* ]]; then
  package-tools repo-bundle generate \
  --repository="${PACKAGE_REPOSITORY}" \
  --version="${REPO_BUNDLE_VERSION}" \
  --sub-version="${REPO_BUNDLE_SUB_VERSION}" \
  --registry="${OCI_REGISTRY}" \
  --package-values-file="${PACKAGE_VALUES_FILE}" \
  --local-registry-url="$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' registry):5000";
fi

if [[ "${OPERATIONS}" == *"repo_bundle_push"* ]]; then
  package-tools repo-bundle push \
  --repository="${PACKAGE_REPOSITORY}" \
  --version="${REPO_BUNDLE_VERSION}" \
  --sub-version="${REPO_BUNDLE_SUB_VERSION}" \
  --registry="${OCI_REGISTRY}";
fi

if [[ "${OPERATIONS}" == *"vendir_sync"* ]]; then
  package-tools vendir sync;
fi
