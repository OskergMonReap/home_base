# Disk Replacement
#### ZFS Mirror disk replacement process

Since every drive is part of a mirror on current desktop setup, all drives are essentially hot-swappable, meaning replaceable while system is powered on.


### Steps
In the below scenario, our zpool is called `zback` and our old/faulty drive (since it's encrypted) is `cryptbad`. Our new/replacement drive is `cryptgood`.

1. First, clear the errors on the drive to see if they continue to increment, indicating the drive is indeed bad and requires replacement
   `zpool clear zback cryptbad`  

2. If drive continues to exhibit issues and your pool is in a degraded state, offline the faulty drive
   `zpool offline -f zback cryptbad`

3. Now we can disconnect the faulty drive, install the new/replacement drive and partition/setup the disk as needed

   First round of partitioning:
   ```
   # This example is for a data drive, ie /backups, not the root/bootable disk
   parted /dev/sda
   mklabel gpt
   mkpart primary ext2 0% 100%
   quit
   ```
   Next, encryption:
   ```
   cryptsetup luksFormat /dev/sda1
   cryptsetup luksOpen /dev/sda1 cryptgood
   ```
   Final partitioning:
   ```
   parted /dev/mapper/cryptgood
   mklabel gpt
   mkpart ext2 0% 100%
   quit
   ```
   Optionally add keyfile to unlock, but always set a password as breakglass
   
4. Now, we let ZFS take the reigns and replace the faulty device within our zpool:
   `zpool replace -f zback cryptbad cryptgood`
