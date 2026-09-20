# Installation

Tu prépares le code **sur le PC de dev**. Tu n’installes la pile **que sur le Raspberry Pi**.

## 1. PC de dev (déjà fait si tu as poussé ce dépôt)

- Éditer docs / scripts / `.env.example`
- `git commit` / `git push` vers GitHub
- Optionnel : extraire des `.pmtiles` ici (x86), puis les copier sur le Pi dans `data/pmtiles/` et `apps/cartoff/pmtiles/`
- **Ne pas** exécuter `sudo ./scripts/install.sh` sur le PC (mauvaise archi, mauvais udev, Docker amd64)

`save-images.sh` sur un PC Intel tire des images **amd64** inutilisables sur le Pi. Pour un air-gap, lance-le **sur le Pi** (ou un hôte ARM64) tant qu’il a internet.

## 2. Image vierge sur le Pi

Flash **Raspberry Pi OS 64-bit** (pas RAKPiOS). Active SSH, Ethernet ou Wi-Fi. Premier boot, note l’IP.

## 3. Sur le Pi (SSH depuis le PC)

Matériel : Pi 4 **8 Go**, **SSD**, deux Seeed USB (câbles data, antennes avant TX), onduleur si crise.

```bash
git clone https://github.com/F4EED/GerMaCrise-Raspberry.git
cd GerMaCrise-Raspberry
cp .env.example .env
nano .env
sudo ./scripts/install.sh
sudo ./scripts/status.sh
```

Le script (sur le Pi seulement) :

1. installe Docker + règles **udev** Seeed ;
2. clone les six dépôts dans `apps/` ;
3. télécharge **go-pmtiles** (ARM64) ;
4. reconstitue le fond Loire Cartoff s’il est découpé dans git ;
5. lance **Portainer** (`:9443` seulement, pas le 8000 Edge) ;
6. lance **EMQX 5.3.2**, portail, Cartoff, MeshQTT ;
7. build/start **GerMaCrise** (`docker-compose.poc.yml` + surcharge Pi).

Le build GerMaCrise sur ARM **peut prendre 30–90 min**. Le portail s’ouvre **depuis le PC** : `http://<IP-du-Pi>/`.

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
