# GerMaCrise-Raspberry

SRV de la valise Gestion de PC GerMaCrise : installation **automatisée** d’un poste de commandement **100 % local** (mesh LoRa, deux Seeed USB, MQTT **EMQX 5.3.2**, main courante, cartes PMTiles, MeshQTT, Portainer).

Ce dépôt ne recopie pas les applications F4EED : le script les **clone** et les **câble** (ports, broker, PostGIS, hors-ligne).

## Démarrage rapide (Pi 4, 8 Go, SSD, internet une fois)

```bash
cd "/home/gmc-poste-2/Apps/raspberry germacrise"
cp .env.example .env
nano .env          # mots de passe EMQX / PostGIS / SECRET_KEY

sudo ./scripts/install.sh
sudo ./scripts/status.sh
```

Ouvre `http://<IP-du-Pi>/` (portail).

Options :

| Commande | Effet |
|---|---|
| `sudo ./scripts/install.sh --offline` | Pas de git/docker pull (images déjà chargées) |
| `sudo ./scripts/install.sh --with-pmtiles` | Extracteur de fonds (besoin d’internet) |
| `sudo ./scripts/install.sh --with-bipper` | Client web USB/BLE Seeed |
| `sudo ./scripts/install.sh --skip-germacrise` | Socle MQTT/cartes sans main courante |
| `sudo ./scripts/save-images.sh` | Archive Docker pour air-gap |
| `sudo ./scripts/load-images.sh` | Restaure l’archive puis `--offline` |

## Documentation

| Fichier | Contenu |
|---|---|
| [docs/architecture.md](docs/architecture.md) | Qui fait quoi, flux radio → PC |
| [docs/installation.md](docs/installation.md) | Détail du script, prérequis |
| [docs/configuration.md](docs/configuration.md) | `.env`, canaux, identifiants |
| [docs/ports.md](docs/ports.md) | Tableau des ports |
| [docs/utilisation.md](docs/utilisation.md) | Maison et gestion de crise |
| [docs/cartes-offline.md](docs/cartes-offline.md) | PMTiles, Cartoff, HTTP Range |
| [docs/radios.md](docs/radios.md) | Deux Seeed USB + MQTT gateway |
| [docs/depannage.md](docs/depannage.md) | Fond gris, MQTT, RAM Pi |

## Règles non négociables

- Broker MQTT = **`emqx:5.3.2`** seulement (pas Mosquitto, pas `latest`).
- Cartes = **PMTiles locaux**, pas OSM.org / MapTiler cloud.
- Un seul PostGIS : celui de **GerMaCrise** (`postgis/postgis:16-3.4`).
- MeshQTT `:8088`, Cartoff `:8001` (évite les 8000/8080 des README amont).

## Dépôts installés

- [GerMaCrise](https://github.com/F4EED/GerMaCrise)
- [cartoff](https://github.com/F4EED/cartoff)
- [pmtiles](https://github.com/F4EED/pmtiles)
- [MeshQTT](https://github.com/F4EED/MeshQTT)
- [client_web_MT_bipper](https://github.com/F4EED/client_web_MT_bipper)
- [Meshcore-carte-region](https://github.com/F4EED/Meshcore-carte-region)
