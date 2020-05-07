# Borgbackup

Borg is a deduplicating archiver with compression and encryption. It takes incremental backups of files you specify, allowing point-in-time recovery of files without wasting space.

#### Installation
`pip install --user borgbackup`

#### Remote Server Configuration
The remote server also requires `borgbackup` to be installed also. Once installed, from our machine we want to backup we run the below command to initialize the repo on remote server:

`borg init --encryption=repokey user@1.1.1.1:/backups/machine`

Replacing `user` with the user you want to use on remote machine (for instance `borg` if you want a common entry point for multiple machines), and `1.1.1.1` for the IP or DNS name of the remote server where the backups we'll be stored.

#### Script

#### Cron
