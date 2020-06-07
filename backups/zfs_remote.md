# Offsite Backups
Hardware failures are unaviodable, to shield myself from data loss due to multiple hardware failures (since all data is part of mirrors, two disk failures within the same mirror) durable remote backups are needed.

My solution will combine `zfs`, `gzip`, and `openssl` to create compressed, encrypted copies of my `zfs` snapshots in file format locally. Then via script, with properly configured `aws cli` we will take advantage of multipart upload to *Amazon S3*.

### Overview
The following steps will be scripted, however these are the individual steps that we will string together.

1. Utilize `zfs send` with pipes to generate our snapshot in file format. The command will consist of two seperate pipes, first the `send` command will be piped to `gzip` to add compression, and finally `gzip` output will be piped to `openssl` to encrypt the compressed file.

```
zfs send zroot/home@autosnap_2020-06-07_20:30:01_hourly | gzip | openssl enc -aes-256-cbc -a -salt > /backups/zfs/cloud/zroot_home_2020-06-07.gz.ssl
```
