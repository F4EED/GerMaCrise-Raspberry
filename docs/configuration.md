# Configuration

Tout part de **`.env`** à la racine (copie de `.env.example`). Ne commite jamais ce fichier.

## Secrets à changer avant la prod / la crise

| Variable | Usage |
|---|---|
| `EMQX_DASHBOARD_PASSWORD` | Console EMQX `:18083` (8 caractères min.) |
| `POSTGRES_PASSWORD` | PostGIS GerMaCrise |
| `SECRET_KEY` | JWT GerMaCrise |
| `MQTT_USER` / `MQTT_PASSWORD` | Préparer l’auth MQTT (à activer dans EMQX) |

`PI_HOST` vide = première IP de `hostname -I`. Les téléphones doivent viser **cette IP**, pas `localhost`.

## Fichiers générés par l’install

| Fichier | Rôle |
|---|---|
| `overlay/meshqtt/settings.json` | Broker `emqx`, topic `msh/EU_868`, canal 0 LongFast, canal 6 `mqtt` |
| `overlay/germacrise.env` | Injecté dans le compose GerMaCrise |
| `apps/pmtiles/.env` | `MQTT_HOST=emqx` (plus `mqtt.gaulix.fr`) |
| `apps/GerMaCrise/.env` | Copie du précédent |

## MeshQTT — canaux

Aligne les **8 slots** avec la radio gateway (Seeed A) :

- index **0** : canal principal (PSK identique à la radio) ;
- index **6** : nom **`mqtt`**, PSK `AQ==`, uplink **et** downlink ON sur la radio ;
- `root_topic` : `msh/EU_868` **sans** slash final.

L’UI MeshQTT peut écraser `settings.json` via `/api/settings`. Après un changement radio, reconnecte depuis l’interface.

## EMQX 5.3.2

Image **figée** `emqx:5.3.2`. Dans le dashboard :

1. change le mot de passe admin ;
2. (recommandé) désactive l’anonyme, crée l’utilisateur `MQTT_USER` ;
3. ACL limitée à `msh/EU_868/#`.

Les nœuds LoRa se connectent à **`PI_HOST:1883`**, pas à `emqx` (ce nom n’existe que sur le réseau Docker).

## GerMaCrise frontend et LAN

`REACT_APP_API_URL=http://<PI_HOST>:8000` est écrit au moment de l’install. Si l’IP DHCP change, régénère `overlay/germacrise.env` et recrée le frontend :

```bash
sudo ./scripts/install.sh --skip-germacrise   # non : il faut relancer GerMaCrise
cd apps/GerMaCrise
docker compose --env-file ../../overlay/germacrise.env \
  -f docker-compose.poc.yml -f ../../compose/germacrise.pi.override.yml \
  up -d frontend
```

Mieux : IP LAN **réservée** sur le routeur / dhcpcd.

## Info Routes / Gaulix public

Laissés **éteints**. Pas d’Inforoute, pas de `mqtt.gaulix.fr`.
