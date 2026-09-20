#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "Arrêt des piles (volumes conservés sauf --purge)"
(
  cd "${ROOT}/compose"
  docker compose --env-file "${ROOT}/.env" --profile outils down || true
)
if [[ -f "${ROOT}/apps/GerMaCrise/docker-compose.poc.yml" ]]; then
  (
    cd "${ROOT}/apps/GerMaCrise"
    docker compose -f docker-compose.poc.yml down || true
  )
fi
if [[ "${1:-}" == "--purge" ]]; then
  docker rm -f portainer crise-emqx crise-portail crise-cartoff crise-meshqtt crise-pmtiles 2>/dev/null || true
  echo "Conteneurs socle supprimés. Volumes Docker NON détruits (PostGIS / EMQX)."
fi
