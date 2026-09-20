#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TAR="${1:-${ROOT}/data/images/crise-pi-images.tar}"
[[ -f "${TAR}" ]] || { echo "Archive introuvable : ${TAR}"; exit 1; }
docker load -i "${TAR}"
echo "Images chargées. Ensuite : sudo ${ROOT}/scripts/install.sh --offline"
