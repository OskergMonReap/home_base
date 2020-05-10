# ZFS Mirror

ZFS is an advanced filesystem developed by Sun Microsystems, when creating a pool you have the option to setup in mirror configuration to gain hardware redundancy. Data will be replicated/shared across the two disks via ZFS (RAID), allowing a drive to fail without losing data. Giving you time to replace and restore from remaining disk.

When creating your pool, after identifying the disks, the below command will create the mirror:
```
zpool create -f -o ashift=12 -m /backups zdata mirror /dev/sdc /dev/sdd
```

**NOTE**: Typically, disks will be identified during my personal ZFS setup via ID. Easy identification of disks with the command `ls -lah /dev/disk/by-id/` 
