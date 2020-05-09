# ZFS

ZFS is an advanced filesystem created by Sun Microsystems with features such as:
- pooled storage (integrated volume management - zpool)
- copy-on-write
- snapshots
- data integrity verification and automatic repair (scrubbing)

It's stable, fast, secure and future-proof. The main feature for block level backups we'll be focusing on is snapshots (enabled by copy-on-write).

## Snapshots

A snapshot is a read-only copy of a filesystem taken at a moment in time. They are incremental, only recording differences between the snapshot and current filesystem. This means that until you make changes to the active filesystem, snapshots will not take up any extra storage. 

Snapshots are cloned, backed up and rolled back to.. never accessed directly.

### Snapshot Creation

Using native ZFS, snapshots are created using `zfs snapshot` command, passing it the name of the snapshot we want to create. If we wanted to create a snapshot for `zpool/data` called `2020-09-05`, we would run the below command:
```
zfs snapshot create zpool/data@2020-09-05
```
> This can be verified afterwards by running `zfs list -t snapshot`
> which will list all snapshots for the system

### Snapshot Deletion

Native ZFS command `zfs destroy` is used in the same fashion as the above `snapshot` command, passing in the snapshot you want to delete. To delete the snapshot from the above example, we would run the below command:
```
zfs destroy zpool/data@2020-09-05
```

### Roll Back

Using the ZFS command `zfs rollback` we can restore the active filesystem to a snapshot. This will delete all changes made since the snapshot was created, reverting the active filesystem to that point in time. Command structure remains the same, passing the name of the snapshot to the `rollback` command.
```
zfs rollback -r zpool/data@2020-09-05
```
> Any snapshots made after the snapshot you have rolled back to must be deleted
> By passing the `-r` flag to the `zfs rollback` command, this is automatically taken care of for you

## Managing Snapshots Automatically

There are a myriad of tools available to manage ZFS snapshots on our behalf, from simple bash scripts that are distributed for general use to software solutions. After reviewing several options, the `sanoid`/`syncoid` solution was chosen for its reliability, rich feature set and ability to manage snapshots and replication independently.
