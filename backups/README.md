# Backups

Backups have three tiers for personal devices; file, block and hardware levels. 

- File refers to the ability to incrementally backup to a remote filesystem at the file level. This means that each file is versioned and restorable from a specific point in time.
- Block refers to the ability to incrementally backup to a remote filesystem at the block, or partition level. This means that each partition, or virtual disk, is versioned and restorable form a specific point in time.

| Backup Level | Technology Used |
| :--- | :--- |
| File | [Borgbackup](borg_backup.md) |
| Block | [ZFS, sanoid, syncoid](zfs.md) |
| Hardware | [ZFS mirrors](zfs_mirror.md) |

