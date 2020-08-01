# Offsite Backups
Local backups galore is nice, but to truly have piece of mind against even a catastrophe that somehow would take out all my devices, remote backups is a must.
AWS provides several storage services, and after some extensive testing (along with weighing cost/benefit for each) I have landed on a primary solution and a secondary solution which can be used ad-hoc.

### Primary Solution
Requirements:
- Following system packages must be installed:
  - `jq`
  - `awscli`
  - `sanoid`/`syncoid`
- IAM user with programmatic access and the following minimum permissions:
```
TO-DO # Use CloudTrail and verify permissions used and craft IAM policy
```

Design:
- Custom AMI with ZFS, sanoid/syncoid installed
- Local script triggered on a timer via cron
  - Use Cloudformation to spin up EC2 instance in us-east-2 based on our custom AMI
    - `Parameter` correlating to AMI ID to be used will be read from file as part of script, IP will be pulled from `dig` command
  - Verify server is up/reachable, trigger syncoid to replicate ZFS snapshots to the instance
  - Trigger new AMI creation from instance (snapshots of volumes are taken during process automatically)
  - Get new AMI ID generated previous script and pipe it to a txt file, overwriting previous
  - Delete Cloudformation stack

*Sample script can be found [here](./cloud/zcloud_back.sh)*

Benefits:
- Incremental backups, push only what has changed after initial push
- EBS Snapshots for point in time backups
- Ephemeral server to keep cost down while keeping transfer speeds respectable
- Script can be reused with minor changes and an additional txt file

### Secondary Solution
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
