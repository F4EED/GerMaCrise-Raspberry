# Dépannage

## Fond de carte gris

1. Pas de `file://` ni `python -m http.server`
2. Cartoff écoute **8001** : `curl -I http://127.0.0.1:8001/`
3. Range : `curl -H "Range: bytes=0-99" -D - -o /dev/null http://127.0.0.1:8001/pmtiles/loire.pmtiles`
4. Fichier absent : `ls apps/cartoff/pmtiles/` puis unpack ou copie
5. Zoom trop bas : les extraits Cartoff / Protomaps commencent souvent au **z9** (`levelDiff: 0`)

## MeshQTT ne voit aucun nœud

- EMQX up : `docker logs crise-emqx`
- Radio A : broker = **IP Pi:1883**, topic `msh/EU_868`
- MeshQTT settings : broker Docker `emqx` (conteneur), pas `mqtt.gaulix.fr`
- `curl http://127.0.0.1:8088/api/mqtt/health`
- Double slash dans le topic si un `/` traîne à la fin du root

## Port déjà pris

| Conflit fréquent | Cause |
|---|---|
| 8000 | Portainer Edge **ou** autre API |
| 8080 | ancien MeshQTT / MeshMonitor |
| 1883 | Mosquitto encore installé (`apt remove mosquitto`) |

Voir [ports.md](ports.md).

## Pi 4 à court de RAM

- GerMaCrise `POSTGIS_MEMORY_LIMIT=768m` (déjà dans l’override)
- Ne pas lancer Grafana + MeshMonitor + extracteur en plus
- SSD, pas swap-only
- `--skip-germacrise` pour tester le socle seul

## GerMaCrise UI sans API depuis un téléphone

`localhost:8000` dans le frontend = le téléphone. Il faut `REACT_APP_API_URL=http://<IP-Pi>:8000` (écrit par l’install). IP DHCP figée.

## Docker « no matching manifest » ARM

Tirer/construire en **linux/arm64**. Les images `emqx:5.3.2`, `postgis/postgis:16-3.4`, `nginx:1.27-alpine` ont un manifest ARM64.

## Install qui re-clone tout

Les dépôts dans `apps/` sont conservés. `git pull` seulement si le réseau est là. En `--offline`, un dossier `apps/X` **sans** `.git` est une erreur (copie incomplète).

## Logs utiles

```bash
docker logs -f crise-emqx
docker logs -f crise-meshqtt
docker logs -f crise-cartoff
docker logs -f germacrise_backend
sudo ./scripts/status.sh
```
