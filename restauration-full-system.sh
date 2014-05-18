#!/bin/bash
#
# Backup full system with rsync
# By Anthony25

#################
# CONFIGURATION #
#################

# TARGET will be "/" if you are restoring a full system backup
TARGET='/'

# SOURCE is the backup directory
SOURCE='/mnt/sda1/Backup/current_backup'

# EXCLUDE is the ignore list.
EXCLUDE='{/dev/*,/proc/*,/sys/*,/tmp/*,/run/*,/mnt/*,/media/*,/lost+found,'
EXCLUDE=$EXCLUDE'/home/*/.gvfs,/srv/ftp/*/*,/srv/nfs/*/*,/var/cache/pacman/*}'

#################


# Check if SOURCE or TARGET exists, are writable and readable

if [ ! -e "$TARGET"  -o ! -r "$TARGET" -o ! -w "$TARGET" ]
    then echo "$TARGET_ROOT could not be read or written"
    exit 0
fi

eval "rsync -aAXHv --delete $SOURCE $TARGET --exclude=$EXCLUDE"
