This is an overview of the start/finish design choices and configurations for desktop PC build.

| Hardware |
| :--- |
| AMD Ryzen 7 3800X |
| Scythe FUMA 2 |
| Asrock x570m Pro 4 |
| Thermaltake V21 Case |
| Crucial Ballistix 64GB (16GB x 4) |
| Sabrent 4.0 Rocket 1TB (x2) |
| Crucial MX500 1TB SSD (x4) |
| Supernova P2 650 PSU |
| AMD 5700 xt GPU |
| BeQuiet SilentWings 140mm (x2) |
| BeQuiet SilentWings 120mm (x3) |

### Disk Layout
![Disk Layout](./images/disk_layout.png)

*Overview of disk layout, ZFS mirrors*

Root will sit on ZFS VDEV mirror, between two Sabrent 4.0 Rocket 1 TB drives. The tentative partitioning is below:
| Location | Size of Partition |
| :--- | :--- |
| /var | 450 GB |
| /opt | 20 GB |
| /tmp | 30 GB |
| /home | 500 GB |

An additional two VDEV mirrors will contain `/backups` and `/plex` directories respectively. Each of these VDEV's will consist of two Crucial MX500 1 TB SSD's, mirrored under ZFS. The `/backups` mirrored VDEV will be utilized for ZFS snapshots and Borgbackup incremental backups. The `/plex` mirrored VDEV will be solely for **PLEX**, which will be dockerized on the host.
