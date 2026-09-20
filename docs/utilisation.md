# Utilisation — maison et crise

La pile ne change pas. Tu t’en sers **tous les jours** à la maison pour que le jour J ce soit un réflexe.

## Routine maison

1. Portail `http://<IP-Pi>/`
2. **GerMaCrise** : tenir l’annuaire (personnel, véhicules, moyens) à jour — même sans crise
3. **MeshQTT** : Connecter, vérifier que Seeed A remonte des nœuds
4. **Cartoff** : fond PMTiles visible, un constat test, export GeoJSON
5. Une fois par mois : `sudo ./scripts/status.sh` + sauvegarde PostGIS (voir ci-dessous)

## Jour de crise (WAN mort)

1. Alim : onduleur → Pi + switch/AP
2. Téléphones sur le **Wi-Fi / Ethernet du Pi** (pas la 4G)
3. Cartoff = situation terrain (routes, zones, SAR)
4. MeshQTT = messages mesh + positions
5. GerMaCrise = main courante, engagements, PCS
6. Bipper seulement **assis devant le Pi** (USB)

Sans le Pi, il reste le LoRa entre nœuds portables, **plus** de carte ni de main courante.

## Sauvegarde

PostGIS :

```bash
docker exec germacrise_db pg_dump -U maincourante main_courante \
  > "/chemin/usb/germacrise-$(date +%F).sql"
```

EMQX : volume `crise-pi_emqx-data` (nom selon le projet compose).  
PMTiles : copie `apps/cartoff/pmtiles/*.pmtiles` et `data/pmtiles/`.  
MeshQTT : `overlay/meshqtt/settings.json` + `apps/MeshQTT/data/`.

## Ce que ça ne remplace pas

Pas le 15/18/112, pas un réseau radio licencié, pas une couverture départementale (Seeed ≈ 22 dBm, quartier / bourg).
