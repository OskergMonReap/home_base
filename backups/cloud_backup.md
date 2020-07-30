# Offsite Backups
Local backups galore is nice, but to truly have piece of mind against even a catastrophe that somehow would take out all my devices, remote backups is a must.
AWS provides several storage services, and I will be exploring the best for my use cases. Below is a list of solutions I've come up with that I will be testing.

### Solution 1
Design:
- Custom AMI with ZFS, sanoid/syncoid installed
- Local script triggered on a timer via cron
  - Use Cloudformation to spin up EC2 instance in us-east-2 based on our custom AMI
    - Single `Parameter` correlating to AMI ID to be used will be read from file as part of script
  - Verify server is up/reachable, trigger syncoid to replicate ZFS snapshots to the instance
  - Trigger new AMI creation from instance (snapshots of volumes are taken during process automatically)
  - Get new AMI ID generated previous script and pipe it to a txt file
  - Delete Cloudformation stack
**Sample script can be found [here](./cloud/zcloud_back.sh)**

Benefits:
- Incremental backups, push only what has changed
- EBS Snapshots for point in time backups
- Ephemeral server to keep cost down while keeping transfer speeds respectable

### Solution 2
Design:
- One-liner commandline alias/script that pipes `zfs send` to:
  - `gzip` for compression
  - `openssl` for encryption
  - `aws-cli` to stream directly into S3 bucket
 ```
 zfs send -R zroot/home@autosnap | gzip -9 | openssl enc -aes-256-cbc -a -salt -k SomePassword | aws s3 cp --expected-size 400000000 - s3://zfs-repo/zroot_home.gz.ssl
 ```

 Benefits:
 - Simplicity of single command/script
 - S3 with lifecycle management automation
 - Encrypted pre-flight

### Solution 3
#### 3A
Design:
- AWS Storage Gateway as VM on Desktop PC
  - Always on, or triggered by script TBD
- Mount /backups (which correlates to `zback` ZFS pool which is a mirror of two drives) to VM
- Let the Storage Gateway replicate to S3

#### 3B
Design:
- AWS Storage Gateway on Raspberry Pi 4 w/ 4 SATA drives configured as 2 ZFS mirrored pools
- Replicate /backups (which correlates to `zback` ZFS pool on desktop) to the Pi
- Let the Storage Gateway replicate to S3
