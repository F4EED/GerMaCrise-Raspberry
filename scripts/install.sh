#!/usr/bin/env bash
# Installation automatisée du poste de crise sur Raspberry Pi 4.
# Usage :
#   cp .env.example .env   # puis éditer les mots de passe
#   sudo ./scripts/install.sh
#   sudo ./scripts/install.sh --offline          # pas de git/docker pull
#   sudo ./scripts/install.sh --skip-germacrise
#   sudo ./scripts/install.sh --with-bipper
#   sudo ./scripts/install.sh --with-pmtiles     # extracteur (besoin d'internet)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OFFLINE=0
SKIP_GERMACRISE=0
WITH_BIPPER=0
WITH_PMTILES=0

log() { printf '\n==> %s\n' "$*"; }
die() { printf 'ERREUR : %s\n' "$*" >&2; exit 1; }

need_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    die "relance avec sudo : sudo $0 $*"
  fi
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --offline) OFFLINE=1 ;;
      --skip-germacrise) SKIP_GERMACRISE=1 ;;
      --with-bipper) WITH_BIPPER=1 ;;
      --with-pmtiles) WITH_PMTILES=1 ;;
      -h|--help)
        sed -n '2,12p' "$0"
        exit 0
        ;;
      *) die "option inconnue : $1" ;;
    esac
    shift
  done
}

load_env() {
  if [[ ! -f "${ROOT}/.env" ]]; then
    cp "${ROOT}/.env.example" "${ROOT}/.env"
    log "Fichier .env créé depuis .env.example — change les mots de passe."
  fi
  set -a
  # shellcheck disable=SC1091
  source "${ROOT}/.env"
  set +a
}

detect_host() {
  local ip
  ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
  if [[ -z "${PI_HOST:-}" ]]; then
    PI_HOST="${ip:-127.0.0.1}"
    log "PI_HOST auto-détecté : ${PI_HOST}"
  fi
  export PI_HOST
}

install_packages() {
  log "Paquets système"
  apt-get update
  apt-get install -y --no-install-recommends \
    ca-certificates curl git jq python3 python3-venv python3-pip \
    udev usbutils
}

install_docker() {
  if command -v docker >/dev/null 2>&1; then
    log "Docker déjà présent"
    return
  fi
  [[ "${OFFLINE}" -eq 1 ]] && die "Docker absent et --offline : installe Docker avant."
  log "Installation Docker"
  curl -fsSL https://get.docker.com | sh
  usermod -aG docker "${SUDO_USER:-pi}" || true
}

install_udev() {
  log "Règles udev Seeed USB"
  install -m 0644 "${ROOT}/overlay/udev/99-seeed-meshtastic.rules" \
    /etc/udev/rules.d/99-seeed-meshtastic.rules
  udevadm control --reload-rules
  udevadm trigger || true
  local user="${SUDO_USER:-pi}"
  usermod -aG dialout "${user}" || true
}

clone_repo() {
  local url="$1" dest="$2"
  if [[ -d "${dest}/.git" ]]; then
    if [[ "${OFFLINE}" -eq 0 ]]; then
      log "Mise à jour ${dest}"
      git -C "${dest}" pull --ff-only || log "git pull ignoré pour ${dest}"
    else
      log "Déjà cloné (offline) : ${dest}"
    fi
    return
  fi
  [[ "${OFFLINE}" -eq 1 ]] && die "Dépôt manquant en offline : ${dest}"
  log "Clone ${url}"
  git clone --depth 1 "${url}" "${dest}"
}

clone_all() {
  mkdir -p "${ROOT}/apps"
  clone_repo https://github.com/F4EED/GerMaCrise.git "${ROOT}/apps/GerMaCrise"
  clone_repo https://github.com/F4EED/cartoff.git "${ROOT}/apps/cartoff"
  clone_repo https://github.com/F4EED/pmtiles.git "${ROOT}/apps/pmtiles"
  clone_repo https://github.com/F4EED/MeshQTT.git "${ROOT}/apps/MeshQTT"
  clone_repo https://github.com/F4EED/client_web_MT_bipper.git "${ROOT}/apps/client_web_MT_bipper"
  clone_repo https://github.com/F4EED/Meshcore-carte-region.git "${ROOT}/apps/Meshcore-carte-region"

  if [[ "${OFFLINE}" -eq 0 && -f "${ROOT}/apps/cartoff/scripts/unpack_large_file.py" ]]; then
    log "Reconstitution du fond Loire Cartoff (si les morceaux sont dans le dépôt)"
    (cd "${ROOT}/apps/cartoff" && python3 scripts/unpack_large_file.py) \
      || log "unpack Cartoff ignoré (fournis tes propres .pmtiles dans data/pmtiles/ et apps/cartoff/pmtiles/)"
  fi
}

download_pmtiles_cli() {
  local dest="${ROOT}/apps/pmtiles/tools"
  mkdir -p "${dest}"
  if [[ -x "${dest}/pmtiles" ]]; then
    log "go-pmtiles déjà présent"
    return
  fi
  [[ "${OFFLINE}" -eq 1 ]] && { log "Pas de go-pmtiles en offline (extraction impossible)."; return; }
  log "Téléchargement go-pmtiles (ARM64 / amd64)"
  local arch url
  arch="$(uname -m)"
  case "${arch}" in
    aarch64|arm64) url="https://github.com/protomaps/go-pmtiles/releases/download/v1.31.2/go-pmtiles_1.31.2_Linux_arm64.tar.gz" ;;
    x86_64) url="https://github.com/protomaps/go-pmtiles/releases/download/v1.31.2/go-pmtiles_1.31.2_Linux_x86_64.tar.gz" ;;
    *) die "architecture non gérée pour go-pmtiles : ${arch}" ;;
  esac
  curl -fsSL "${url}" | tar -xz -C "${dest}" pmtiles
  chmod +x "${dest}/pmtiles"
}

write_configs() {
  log "Génération des fichiers de config"
  mkdir -p "${ROOT}/overlay/meshqtt" "${ROOT}/data/pmtiles" "${ROOT}/data/images"
  if [[ ! -s "${ROOT}/overlay/meshqtt/settings.json" ]]; then
    install -m 0644 "${ROOT}/overlay/meshqtt/settings.json.example" \
      "${ROOT}/overlay/meshqtt/settings.json"
  else
    log "MeshQTT settings.json existant conservé (PSK / canaux)"
  fi

  umask 077
  cat > "${ROOT}/overlay/germacrise.env" <<EOF
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=${POSTGRES_DB}
SECRET_KEY=${SECRET_KEY}
DB_PORT=${GERMACRISE_DB_PORT:-5433}
BACKEND_PORT=${GERMACRISE_API_PORT:-8000}
FRONTEND_PORT=${GERMACRISE_UI_PORT:-3000}
VISU_PORT=${GERMACRISE_VISU_PORT:-3080}
CARTO_PORT=${GERMACRISE_CARTO_PORT:-3081}
REACT_APP_API_URL=http://${PI_HOST}:${GERMACRISE_API_PORT:-8000}
REACT_APP_API_URL_EXTERNAL=http://${PI_HOST}:${GERMACRISE_API_PORT:-8000}
PI_HOST=${PI_HOST}
POSTGIS_MEMORY_LIMIT=${POSTGIS_MEMORY_LIMIT:-768m}
EOF

  if [[ -d "${ROOT}/apps/GerMaCrise" ]]; then
    cp "${ROOT}/overlay/germacrise.env" "${ROOT}/apps/GerMaCrise/.env"
  fi

  if [[ -d "${ROOT}/apps/pmtiles" ]]; then
    cat > "${ROOT}/apps/pmtiles/.env" <<EOF
MQTT_HOST=emqx
MQTT_PORT=1883
MQTT_USER=${MQTT_USER:-}
MQTT_PASS=${MQTT_PASSWORD:-}
MESHTASTIC_AES_KEY=1PG7OiApB1nwvP+rz05pAQ==
EOF
  fi

  mkdir -p "${ROOT}/apps/MeshQTT/data"
}

install_portainer_safe() {
  if docker ps -a --format '{{.Names}}' | grep -qx portainer; then
    log "Portainer déjà installé"
    docker start portainer >/dev/null || true
    return
  fi
  log "Portainer (uniquement HTTPS ${PORTAINER_PORT:-9443}, pas de port 8000 Edge)"
  docker volume create portainer_data >/dev/null
  docker run -d \
    --name portainer \
    --restart=always \
    -p "${PORTAINER_PORT:-9443}:9443" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    "${PORTAINER_IMAGE:-portainer/portainer-ce:2.27.4}"
}

compose_socle() {
  log "Stack socle : EMQX 5.3.2 + portail + Cartoff + MeshQTT"
  local extra=()
  if [[ "${WITH_PMTILES}" -eq 1 ]]; then
    extra+=(--profile outils)
  fi
  (
    cd "${ROOT}/compose"
    docker compose --env-file "${ROOT}/.env" "${extra[@]}" up -d --build
  )
}

compose_germacrise() {
  [[ "${SKIP_GERMACRISE}" -eq 1 ]] && { log "GerMaCrise ignoré"; return; }
  log "GerMaCrise (PostGIS 16-3.4) — le build ARM peut durer longtemps"
  (
    cd "${ROOT}/apps/GerMaCrise"
    docker compose \
      --env-file "${ROOT}/overlay/germacrise.env" \
      -f docker-compose.poc.yml \
      -f "${ROOT}/compose/germacrise.pi.override.yml" \
      up -d --build
  )
}

install_bipper() {
  [[ "${WITH_BIPPER}" -eq 1 ]] || { log "Bipper non installé (passe --with-bipper)."; return; }
  log "Bipper (client web USB/BLE) — long sur Pi 4"
  bash "${ROOT}/apps/client_web_MT_bipper/install.sh"
}

print_summary() {
  cat <<EOF

Installation terminée.

  Portail            http://${PI_HOST}:${PORTAIL_PORT:-80}/
  GerMaCrise         http://${PI_HOST}:${GERMACRISE_UI_PORT:-3000}/
  Cartoff            http://${PI_HOST}:${CARTOFF_PORT:-8001}/
  MeshQTT            http://${PI_HOST}:${MESHQTT_PORT:-8088}/
  EMQX 5.3 dashboard http://${PI_HOST}:${EMQX_DASHBOARD_PORT:-18083}/
  Portainer          https://${PI_HOST}:${PORTAINER_PORT:-9443}/
  Carto GerMaCrise   http://${PI_HOST}:${GERMACRISE_CARTO_PORT:-3081}/
  Régions MeshCore   http://${PI_HOST}:${PORTAIL_PORT:-80}/meshcore-regions/

MQTT : ${PI_HOST}:${EMQX_MQTT_PORT:-1883}  root topic ${MQTT_ROOT_TOPIC:-msh/EU_868}
Image EMQX figée : emqx:5.3.2  (pas latest, pas Mosquitto)

Docs : ${ROOT}/docs/
État : sudo ${ROOT}/scripts/status.sh

Branche les deux Seeed en USB, antennes montées, puis suis docs/radios.md
EOF
}

main() {
  parse_args "$@"
  need_root "$@"
  load_env
  detect_host
  if [[ "${OFFLINE}" -eq 0 ]]; then
    install_packages
    install_docker
  else
    command -v docker >/dev/null || die "Docker requis en --offline"
  fi
  install_udev
  clone_all
  download_pmtiles_cli
  write_configs
  install_portainer_safe
  compose_socle
  compose_germacrise
  install_bipper
  print_summary
}

main "$@"
