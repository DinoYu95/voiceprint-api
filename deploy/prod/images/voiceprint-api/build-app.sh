#!/usr/bin/env bash
# 【仅生产】构建并推送 voiceprint-api App 到 ACR（日常发版执行）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT"

ENV_FILE="${ROOT}/deploy/prod/images/acr.env"
if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

REGISTRY="${ACR_REGISTRY:?set ACR_REGISTRY in deploy/prod/images/acr.env}"
NS="${ACR_NAMESPACE:?set ACR_NAMESPACE}"
BASE_TAG="${VP_BASE_TAG:-latest}"
APP_TAG="${VP_APP_TAG:?set VP_APP_TAG}"
BASE_IMAGE="${REGISTRY}/${NS}/voiceprint-api-base:${BASE_TAG}"
IMAGE="${REGISTRY}/${NS}/voiceprint-api:${APP_TAG}"
DOCKERFILE="${ROOT}/deploy/prod/images/voiceprint-api/Dockerfile.app"

echo "==> [prod] build voiceprint app: ${IMAGE}"
echo "    FROM ${BASE_IMAGE}"
docker build -f "${DOCKERFILE}" \
  --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
  -t "${IMAGE}" .

if [[ "${PUSH:-1}" == "1" ]]; then
  echo "==> [prod] push voiceprint app: ${IMAGE}"
  docker push "${IMAGE}"
fi

echo "Done. deploy/prod/.env.prod:"
echo "VOICEPRINT_IMAGE=${IMAGE}"
