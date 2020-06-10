## Installation for custom Desktop PC Build
Connect ethernet to your machine, then using a custom Arch Linux iso (steps to create [here](https://www.github.com/OskergMonReap/arch_on_zed_fs)) boot from usb into the live environment.

Set system time and run through first round of partitioning:

1. Partition what will become our boot and root and format the boot partitions:
```
timedatectl set-ntp true

parted /dev/nvme01
mklabel gpt
mkpart ESP fat32 1MiB 513MiB
set 1 boot on
mkpart primary ext2 513MiB 99%
align-check optimal 1
align-check optimal 2
quit

parted /dev/nvme02
mklabel gpt
mkpart ESP fat32 1MiB 513MiB
set 1 boot on
mkpart primary ext2 513MiB 99%
align-check optimal 1
align-check optimal 2
quit

mkfs.fat -F32 /dev/nvme01p1
mkfs.fat -F32 /dev/nvme02p1
```

2. Now LUKs encrypt the second partition, open them and repartition for ZFS:
```
cryptsetup luksFormat /dev/nvme01p2
cryptsetup luksFormat /dev/nvme02p2
cryptsetup luksOpen /dev/nvme01p2 cryptroot-a
cryptsetup luksOpen /dev/nvme02p2 cryptroot-b

parted /dev/mapper/cryptroot-a
mklabel gpt
mkpart ext2 0% 100%
quit

parted /dev/mapper/cryptroot-b
mklabel gpt
mkpart ext2 0% 100%
quit
```

3. Setup ZFS
```
touch /etc/zfs/zpool.cache
zpool create -o cachefile=/etc/zfs/zpool.cache -m none -R /mnt zroot mirror /dev/mapper/cryptroot-a /dev/mapper/cryptroot-b
```
