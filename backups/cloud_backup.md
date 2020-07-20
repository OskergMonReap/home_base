# Offsite Backups
Local backups galore is nice, but to truly have piece of mind against even a catastrophe that somehow would take out all my devices, remote backups is a must.
AWS provides several storage services, and I will be exploring the best for my use cases. Below is a list of solutions I've come up with that I will be testing.

### Solution 1
Design: 
- Custom AMI with ZFS, sanoid/syncoid installed
- Local script triggered on a timer via cron
  - Use Cloudformation to spin up EC2 instance in us-east-2 based on our custom AMI
  - Verify server is up/reachable, trigger syncoid to replicate ZFS snapshots to the instance
  - Delete Cloudformation stack

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
 zfs send -R zroot/home@autosnap | gzip -9 | openssl enc -aes-256-cbc -a -salt -pbkdf2 SomePassword | aws s3 cp --expected-size 400000000 - s3://zfs-repo/zroot_home.gz.ssl
 ```
 
 Benefits:
 - Simplicity of single command/script
 - S3 with lifecycle management automation
 - Encrypted pre-flight
