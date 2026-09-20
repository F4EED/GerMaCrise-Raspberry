# Ports

Un seul service par port. Les README amont (MeshQTT 8080, Cartoff 8000, Portainer Edge 8000) sont **écartés** volontairement.

| Service | Port | URL type |
|---|---|---|
| Portail | **80** | `http://PI/` |
| GerMaCrise UI | **3000** | `http://PI:3000/` |
| GerMaCrise API | **8000** | `http://PI:8000/` |
| Cartoff | **8001** | `http://PI:8001/` |
| Extracteur PMTiles | **8002** | `http://PI:8002/` (profil `outils`) |
| MeshQTT | **8088** | `http://PI:8088/` |
| Carto GerMaCrise nginx | **3081** | `http://PI:3081/` |
| Visu GerMaCrise | **3080** | `http://PI:3080/` |
| PostGIS | **5433** | `localhost:5433` (QGIS) |
| EMQX MQTT | **1883** | radios + MeshQTT |
| EMQX dashboard | **18083** | `http://PI:18083/` |
| Portainer | **9443** | `https://PI:9443/` |
| Bipper | **5173** | `http://localhost:5173/` **sur le Pi** |
| MeshCore régions | 80 `/meshcore-regions/` | portail |

Portainer **n’expose pas** 8000 (Edge) pour ne pas tuer l’API GerMaCrise.
