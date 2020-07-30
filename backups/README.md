# Backups

Backups have three tiers for personal devices; file, block and hardware levels. 

- File refers to the ability to incrementally backup to a remote filesystem at the file level. This means that each file is versioned and restorable from a specific point in time.
- Block refers to the ability to incrementally backup to a remote filesystem at the block, or partition level. This means that each partition, or virtual disk, is versioned and restorable form a specific point in time.
- Hardware is self explanatory, ability to endure hard drive failures without data loss

| Backup Level | Technology Used |
| :--- | :--- |
| File | [Borgbackup](borg_backup.md) |
| Block | [ZFS, sanoid, syncoid](zfs.md) |
| Hardware | [ZFS mirrors](zfs_mirror.md) |
| Remote | [Cloud Storage](cloud_backup.md) |

#### TO-DO
Offsite backups
> Investigate AWS Storage Gateway (Volume Gateway) with ZFS to allow snapshots to automatically be synced to S3
>
> Investigate script to spin up EC2 instance from AMI (with ZFS enabled and an EBS volume mounted via ZFS cachefile), use syncoid to replicate to EC2, create new AMI (which automatically snapshots EBS volumes for EBS-backed instances) and then tear down the instance to save on costs
>
> If offsite backups end up being a rare (monthly, or even every few months) then considering piping a `zfs send` command directly to the `aws cp -` command to simply send the ZFS snapshot directly to a file on s3.. this would allow super simple script along with compression/encryption inline..
