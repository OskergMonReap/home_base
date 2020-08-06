# Backups

Locally, backups have three tiers for personal devices; file, block and hardware levels. Final piece of the puzzle is remote backups for complete piece of mind.

- File refers to the ability to incrementally backup to a remote filesystem at the file level. This means that each file is versioned and restorable from a specific point in time.
- Block refers to the ability to incrementally backup to a remote filesystem at the block, or partition level. This means that each partition, or virtual disk, is versioned and restorable form a specific point in time.
- Hardware is self explanatory, ability to endure hard drive failures without data loss

| Backup Level | Technology Used |
| :--- | :--- |
| File | [Borgbackup](borg_backup.md) |
| Block | [ZFS, sanoid, syncoid](zfs.md) |
| Hardware | [ZFS mirrors](zfs_mirror.md) |
| Remote | [Cloud Storage](cloud_backup.md) |
