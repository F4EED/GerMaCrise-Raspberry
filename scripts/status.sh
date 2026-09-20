#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
[[ -f "${ROOT}/.env" ]] && source "${ROOT}/.env"
HOST="${PI_HOST:-$(hostname -I 2>/dev/null | awk '{print $1}')}"
HOST="${HOST:-127.0.0.1}"

check() {
  local name="$1" url="$2"
  if curl -fsS -m 4 -o /dev/null "$url"; then
    printf 'OK   %s  %s\n' "$name" "$url"
  else
    printf 'FAIL %s  %s\n' "$name" "$url"
  fi
}

echo "Hôte : ${HOST}"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' || true
echo
check portail "http://${HOST}:${PORTAIL_PORT:-80}/"
check cartoff "http://${HOST}:${CARTOFF_PORT:-8001}/"
check meshqtt "http://${HOST}:${MESHQTT_PORT:-8088}/api/status"
check emqx "http://${HOST}:${EMQX_DASHBOARD_PORT:-18083}/"
check germacrise "http://${HOST}:${GERMACRISE_UI_PORT:-3000}/"
echo
echo "USB Seeed :"
ls -l /dev/ttyACM* /dev/seeed-meshtastic-* 2>/dev/null || echo "(aucun ttyACM pour l'instant)"
