# Offsite Backups
Hardware failures are unaviodable, to shield myself from data loss due to multiple hardware failures (since all data is part of mirrors, two disk failures within the same mirror) durable remote backups are needed.

My solution will combine `zfs`, `gzip`, and `openssl` to create compressed, encrypted copies of my `zfs` snapshots in file format locally. Then via script, with properly configured `aws cli` we will take advantage of multipart upload to *Amazon S3*.

### Overview
The following steps will be scripted, however these are the individual steps that we will string together.

1. Utilize `zfs send` with pipes to generate our snapshot in file format. The command will consist of two seperate pipes, first the `send` command will be piped to `gzip` to add compression, and finally `gzip` output will be piped to `openssl` to encrypt the compressed file.

```
zfs send zroot/home@autosnap_2020-06-07_20:30:01_hourly | gzip | openssl enc -pbkdf2 -a -salt > /backups/zfs/cloud/zroot_home_2020-06-07.gz.ssl
```

2. Finally, the compressed/encrypted file will be sent to *Amazon S3* via `aws cli` commands. 

First, to make use of more of our machines bandwidth we will adjust the default `max_concurrent_requests` for *S3* with the below command, this only needs to be ran once so we perform this step manually:  
`aws configure set default.s3.max_concurrent_requests 20`

Now, since the `aws cli` is intelligent enough to automatically utilize multipart upload for large files, we just run the `cp` command and let the tooling do the rest:
```
aws s3 cp /backups/zfs/cloud/zroot_home_2020-06-07.gz.ssl s3://zfs-repo/zroot_home_2020-06-07.gz.ssl
```

### Script Considerations
The above is perfectly usable, however it has flaws as is that we need to address with our script:
1. We have to know the snapshot name, which are typically long and unintuitive to simply type out
> Generate a list of snapshots and allow interactive selection which will automatically add the snapshot to our send command

2. As it stands, all snapshot files will be uploaded to a flat bucket structure. When the need to restore from one of these arises, it places the burden on the user to comb through an unwieldy list
> Create a path structure, based on date, for each object before upload
> For example, parse file name for date, and then generate the new path for upload with it as prefix
> `2020-06-07/zroot_home.gz.ssl`, notice we dropped the redundant date from our actual file during upload

