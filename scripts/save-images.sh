#!/usr/bin/env bash
# Sauvegarde les images Docker pour un déploiement 100 % hors-ligne.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
[[ -f "${ROOT}/.env" ]] && source "${ROOT}/.env"
OUT="${ROOT}/data/images"
mkdir -p "${OUT}"
IMAGES=(
  "${EMQX_IMAGE:-emqx:5.3.2}"
  nginx:1.27-alpine
  python:3.12-slim-bookworm
  postgis/postgis:16-3.4
  "${PORTAINER_IMAGE:-portainer/portainer-ce:2.27.4}"
)
log_file="${OUT}/images.txt"
: > "${log_file}"
for img in "${IMAGES[@]}"; do
  echo "pull ${img}"
  docker pull "${img}"
  echo "${img}" >> "${log_file}"
done
tar="${OUT}/crise-pi-images.tar"
echo "docker save → ${tar}"
# shellcheck disable=SC2086
docker save "${IMAGES[@]}" -o "${tar}"
echo "OK ${tar}"
echo "Sur le Pi isolé : docker load -i ${tar}"
