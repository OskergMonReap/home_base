# Docker Ecosystem

Docker is used to host applications for local use, reachable only via home network. All applications will have their own specific `docker-compose` files in order to allow independent updates/updates.

## Applications
| Application | `docker-compose` File |
| --- | --- |
| Anchore | [anchore-compose.yml](anchore-compose.yml) |
| ELK Stack | [elastic-compose.yml](./elk_stack/docker-compose.yml) |
| Plex** | [plex-compose.yml](plex-compose.yml) |
| TeamCity | [teamcity.yml](./teamcity/docker-compose.yml) |

**Plex docker deployment is deprecated, no longer deployed via Docker. `pac -S plex-media-server-plexpass` and then `sudo systemctl enable plexmediaserver` which allows Plex to easily use GPU
