# Architecture

Le Raspberry Pi 4 est le **serveur always-on**. Les deux kits Seeed (XIAO ESP32S3 + Wio-SX1262) sont des **radios Meshtastic USB**, pas une WisMesh Station.

```
Téléphones / PC  ──►  Portail :80
                         │
         ┌───────────────┼────────────────┬─────────────┐
         ▼               ▼                ▼             ▼
    GerMaCrise        Cartoff          MeshQTT       EMQX 5.3.2
    UI :3000          :8001            :8088         MQTT :1883
    API :8000         PMTiles          nodeless      Dashboard :18083
    PostGIS :5433
         ▲
         └── BAN + main courante (PCS / PICS)

Seeed A USB ── MQTT (Wi-Fi LAN du Pi ou via gateway) ──► EMQX
Seeed B USB ── Bipper Web Serial (:5173)  /  2ᵉ canal
```

## Rôle de chaque dépôt F4EED

| Dépôt | Rôle ici |
|---|---|
| **GerMaCrise** | Main courante, personnel, moyens, BAN, **PostGIS** |
| **cartoff** | Carte **opérationnelle** 100 % offline (constats, DFCI, SAR) |
| **pmtiles** | **Usine** d’extraits `.pmtiles` (internet **une fois**) + suivi mesh optionnel |
| **MeshQTT** | PC mesh sans radio dans le navigateur (messages, nœuds, downlink) |
| **client_web_MT_bipper** | Config / alertes USB-BLE des Seeed **sur le Pi** |
| **Meshcore-carte-region** | Commandes CLI régions MeshCore (fichiers statiques) |

## Ce qui n’est pas installé par défaut

- Mosquitto
- MeshMonitor / TileServer GL (la carto F4EED est en PMTiles)
- Broker public `mqtt.gaulix.fr`

## Maison vs crise

Même pile. Internet ne sert qu’à cloner, tirer les images Docker, extraire des PMTiles. Le jour J, WAN coupé : LoRa + LAN du Pi + cartes disque.
