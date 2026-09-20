# Installation

## Matériel

- Raspberry Pi 4 **8 Go**, OS 64-bit, **SSD** (la SD suffit à peine)
- Deux [Seeed XIAO ESP32S3 + Wio-SX1262](https://www.seeedstudio.com/Wio-SX1262-with-XIAO-ESP32S3-p-5982.html), câbles USB **data**, antennes LoRa **avant** d’émettre
- Onduleur si usage crise

## Première fois (avec internet)

```bash
cd "/chemin/vers/raspberry germacrise"
cp .env.example .env
nano .env
sudo ./scripts/install.sh
```

Le script :

1. installe Docker + règles **udev** Seeed ;
2. clone les six dépôts dans `apps/` ;
3. télécharge **go-pmtiles** (ARM64 sur Pi) ;
4. reconstitue le fond Loire Cartoff s’il est découpé dans git ;
5. lance **Portainer** (`:9443` seulement, pas le 8000 Edge) ;
6. lance **EMQX 5.3.2**, portail, Cartoff, MeshQTT ;
7. build/start **GerMaCrise** (`docker-compose.poc.yml` + surcharge Pi).

Le build GerMaCrise sur ARM **peut prendre 30–90 min**.

### Options

```bash
sudo ./scripts/install.sh --with-pmtiles   # extracteur :8002
sudo ./scripts/install.sh --with-bipper    # Node + Chromium, lourd
sudo ./scripts/install.sh --skip-germacrise
sudo ./scripts/install.sh --offline
```

## Préparer un Pi sans internet

Sur une machine en ligne (même archi **linux/arm64** si cible Pi) :

```bash
./scripts/save-images.sh
# copie aussi le dossier du projet + apps/ déjà clonés
```

Sur le Pi :

```bash
sudo ./scripts/load-images.sh /chemin/crise-pi-images.tar
sudo ./scripts/install.sh --offline
```

Les `.pmtiles` doivent déjà être dans `apps/cartoff/pmtiles/` et `data/pmtiles/`.

## Après install

```bash
sudo ./scripts/status.sh
```

Premier compte **Portainer** : créé au premier HTTPS `:9443`.  
**EMQX** : `admin` / mot de passe `EMQX_DASHBOARD_PASSWORD` du `.env`.  
**GerMaCrise** : voir le README amont (admin créé par le seed si tu lances `docker compose run --rm seed`).

Seed GerMaCrise (données fictives + BAN) :

```bash
cd apps/GerMaCrise
docker compose --env-file ../../overlay/germacrise.env \
  -f docker-compose.poc.yml run --rm seed
```

## Mise à jour

```bash
sudo ./scripts/install.sh
```

(`git pull` de chaque app si le réseau est là, puis recreate des conteneurs.)

## Désinstall

```bash
sudo ./scripts/uninstall.sh          # stop
sudo ./scripts/uninstall.sh --purge  # supprime les conteneurs socle, pas les volumes
```
