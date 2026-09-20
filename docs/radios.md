# Radios Seeed USB

Deux kits [Wio-SX1262 + XIAO ESP32S3](https://www.seeedstudio.com/Wio-SX1262-with-XIAO-ESP32S3-p-5982.html). Firmware Meshtastic **sur le XIAO**, pas `meshtasticd` sur le Pi.

## Rôles conseillés

| Module | Rôle |
|---|---|
| **A** | Gateway MQTT → EMQX `PI:1883`, topic `msh/EU_868`, JSON ON, canal 6 nommé `mqtt` downlink ON, rôle ROUTER |
| **B** | USB Bipper (config, pager) **ou** second canal / MeshCore — pas deux ROUTER sur la même freq |

Câble **data**, antenne **avant** TX. Hub USB alimenté si le Pi sature.

## Périphériques

Après udev :

```bash
ls -l /dev/ttyACM* /dev/seeed-meshtastic-*
```

Vendor typique Espressif `303a`. Si les liens manquent :

```bash
udevadm info -a -n /dev/ttyACM0 | grep -E 'idVendor|idProduct|serial'
```

Adapte `overlay/udev/99-seeed-meshtastic.rules` puis `sudo ./scripts/install.sh` (recharge udev).

Groupe `dialout` : **reconnexion SSH** après le premier install.

## MQTT sur Seeed A (module Meshtastic)

Dans Bipper ou l’app (USB) :

- Broker : **IP du Pi**, port **1883** (pas `127.0.0.1` sur la radio)
- Root : `msh/EU_868` sans `/` final
- Encryption MQTT **OFF** sur broker privé, JSON **ON**
- Uplink canal 0 + downlink canaux utilisés
- Slot 6 : nom `mqtt`

Le Wi-Fi du XIAO vise le **LAN / AP du Pi**, pas internet.

## Bipper (`--with-bipper`)

Uniquement sur le **Pi** : `http://localhost:5173` (Web Serial / Web Bluetooth ne traverse pas le réseau). Chromium, PIN Gaulix souvent `123456`. Ne pas appairer le nœud dans les paramètres Bluetooth du bureau avant le navigateur.

Firmware cible Gaulix : voir le README [client_web_MT_bipper](https://github.com/F4EED/client_web_MT_bipper) (`seeed-xiao-s3-gaulix`).
