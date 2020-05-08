# Borgbackup

Borg is a deduplicating archiver with compression and encryption. It takes incremental backups of files you specify, allowing point-in-time recovery of files without wasting space.

#### Installation
`pip install --user borgbackup`

#### Remote Server Configuration
The remote server also requires `borgbackup` to be installed also. Once installed, from our machine we want to backup we run the below command to initialize the repo on remote server:

`borg init --encryption=repokey user@1.1.1.1:/backups/machine`

Replacing `user` with the user you want to use on remote machine (for instance `borg` if you want a common entry point for multiple machines), and `1.1.1.1` for the IP or DNS name of the remote server where the backups we'll be stored.

#### Script

Below is a sample script, to be placed within `~/.local/` directory. This will be edited to fit the device it will be ran from as you choose what to include/exclude:

```
#!/bin/sh

# These will be removed from script and handled via ENV variables on the host machine
export BORG_REPO=borg@1.1.1.1:/backups/machine/
export BORG_PASSPHRASE='somepassword'

# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

info "Starting backup"

# Backup the most important directories into an archive named after
# the machine this script is currently running on:

/home/oskr_grme/.local/bin/borg create                         \
    --verbose                       \
    --filter AME                    \
    --list                          \
    --stats                         \
    --show-rc                       \
    --compression lzma,9            \
    --exclude-caches                \
    --exclude '/home/*/.cache/*'    \
    --exclude '/var/cache/*'        \
    --exclude '/var/tmp/*'          \
    --exclude '/var/lib/*'          \
    --exclude '/var/log/*'          \
    --exclude '/var/db/*'          \
    --exclude '/var/spool/*'          \
    --exclude '/etc/audisp/*'          \
    --exclude '/etc/audit/*'          \
    --exclude '/etc/metricbeat/*'          \
    --exclude '/etc/ppp/*'          \
    --exclude '/etc/opt/*'          \
    --exclude '/etc/opt'          \
    --exclude '/etc/.pwd.lock'          \
    --exclude '/etc/rkhunter.conf'          \
    --exclude '/etc/filebeat/*'          \
    --exclude '/etc/pacman.d/*'          \
    --exclude '/etc/libaudit.conf'          \
    --exclude '/etc/sudoers.d'          \
    --exclude '/etc/sudoers'          \
    --exclude '/etc/crypttab'          \
    --exclude '/etc/ssh/ssh_host_dsa_key'          \
    --exclude '/etc/ssh/ssh_host_ecdsa_key'          \
    --exclude '/etc/ssh/ssh_host_ed25519_key'          \
    --exclude '/etc/ssh/ssh_host_rsa_key'          \
    --exclude '/etc/polkit-1/*'          \
    --exclude '/etc/shadow'          \
    --exclude '/etc/shadow-'          \
    --exclude '/etc/gshadow'          \
    --exclude '/etc/gshadow-'          \
    --exclude '/etc/.#gshadowTtStMk'   \
    --exclude '/etc/wireguard/*'          \
    --exclude '/etc/wireguard'          \
    --exclude '/etc/default/*'          \
    --exclude '/etc/zfs/zed.d/*'          \
    --exclude '/etc/NetworkManager/*'          \
    --exclude '/etc/NetworkManager'          \
    --exclude '/etc/opt/*'          \
    --exclude '/etc/docker/*'          \
    --exclude '/etc/udev/rules.d/*'          \
    --exclude '/home/*/__pycache__/*' \
    --exclude '/home/*/.mozilla/*' \
    --exclude '/home/*/Downloads/*' \
    --exclude '/home/*/Development/*' \
    --exclude '/home/*/node_modules/*' \
    --exclude '/home/oskr_grme/.venvs' \
    --exclude '/home/oskr_grme/.vim/*' \
    --exclude '/home/oskr_grme/.local/lib/*' \
    --exclude '/home/oskr_grme/.local/bin/*' \
    --exclude '/home/*/.config/*' \
    --exclude '/home/*/.npm/*' \
    --exclude '/home/*/Build/*' \
                                    \
                                  ::arkroot_$( date "+%m_%d_%y_%H_%M" )            \
    /etc                            \
    /home                           \
    /var                            \

backup_exit=$?

info "Pruning repository"

# Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly
# archives of THIS machine. The '{hostname}-' prefix is very important to
# limit prune's operation to this machine's archives and not apply to
# other machines' archives also:

/home/oskr_grme/.local/bin/borg prune                          \
    --list                          \
    --prefix 'arkroot_'          \
    --show-rc                       \
    --keep-daily    7               \
    --keep-weekly   4               \
    --keep-monthly  6               \

prune_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

if [ ${global_exit} -eq 0 ];
then
    echo "Backup and Prune finished successfully. $( date )"
fi

if [ ${global_exit} -eq 1 ];
then
    echo "Backup and/or Prune finished with a warning. $( date )"
fi

if [ ${global_exit} -gt 1 ];
then
    echo "Backup and/or Prune failed. $( date )"
fi

exit ${global_exit}
```

Exclusions are all handled towards the top, all handled via `--exclude` followed by path which supports globbing.
Inclusions are handled below the exclusions section, listing just directories to include in backups.

#### Cron

The script will be handled by a cron job, set to run every hour. Run `crontab -e` and add the below line:
```
0 * * * * /home/$USER/.local/borgkp.sh >> /home/$USER/.local/logs/borgbackup.log 2>&1
```

This will run the script every hour, and log output to logfile located at `~/.local/logs/borgbackup.log`. Create the directory and file before running/testing cron job.
