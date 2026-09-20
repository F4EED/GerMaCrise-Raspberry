# Cartes 100 % hors-ligne

Les fonds **OSM.org / MapTiler / Google** sont interdits en crise. Format : **PMTiles** + serveur qui parle **HTTP Range**.

## Où vivent les fichiers

| Chemin | Usage |
|---|---|
| `apps/cartoff/pmtiles/*.pmtiles` | Fond Cartoff (`loire.pmtiles` après unpack) |
| `data/pmtiles/` | Tes extraits (maison, zone de repli) |
| `apps/GerMaCrise/.../cartographie/pmtiles/` | Fond UI GerMaCrise (`mymap.pmtiles` selon le README amont) |

Ne **jamais** ouvrir `index.html` en `file://`. Ne **jamais** `python -m http.server` : pas de Range → **fond gris**.

## Extraire une zone (tant que la fibre marche)

```bash
sudo ./scripts/install.sh --with-pmtiles
```

Puis `http://<IP-Pi>:8002/` → sélectionner 4 points → archive dans `apps/pmtiles/pmtiles/` (monté aussi sur `data/pmtiles`).

Copie le fichier vers Cartoff :

```bash
cp data/pmtiles/ma-zone.pmtiles apps/cartoff/pmtiles/
```

Zoom utile : **9–15**. Au-delà le fond Protomaps n’a souvent plus de tuiles.

Binaire : `apps/pmtiles/tools/pmtiles` (**Linux_arm64** sur Pi, pas x86_64).

## Après extraction : couper internet

L’extracteur a besoin de `build.protomaps.com`. La **consultation** Cartoff / GerMaCrise n’en a plus besoin.

## Nginx GerMaCrise `:3081`

Doit servir les `.pmtiles` avec Range (`Accept-Ranges: bytes`). Si fond gris dans GerMaCrise, teste :

```bash
curl -s -D - -o /dev/null -H "Range: bytes=0-99" \
  http://127.0.0.1:3081/pmtiles/mymap.pmtiles | head
```

Attendu : `206 Partial Content`.

## Téléphones

Organic Maps / OsmAnd avec **les mêmes extraits** préchargés : l’app Meshtastic n’utilise pas Cartoff.
