#!/bin/bash
#
# Backup full system with rsync
# By Anthony25

#################
# CONFIGURATION #
#################

# TARGET will be "/" if you are restoring a full system backup
TARGET='/'

# EXCLUDE is the ignore list.
EXCLUDE='{/dev/*,/proc/*,/sys/*,/tmp/*,/run/*,/mnt/*,/media/*,/lost+found,'
EXCLUDE=$EXCLUDE'/home/*/.gvfs,/srv/ftp/*/*,/srv/nfs/*/*,/var/cache/pacman/*}'

#################


print_help()
{
    echo -e "Restore backup.\n"
    echo "restauration-full-system.sh BACKUP_DIR"
    echo -e "    BACKUP_DIR: backup root to restore\n"
    echo "Options:"
    echo "    -h: Print help"
    echo "    -o FILE: Log the output in FILE"
    exit 0
}


while getopts "ho:i" OPTION
do
    case $OPTION in
        h)
            print_help
            ;;
        ?)
            print_help
            ;;
    esac
done

# SOURCE is the backup directory
SOURCE='/mnt/sda1/Backup/current_backup'
if [ ! -e "$1" -o ! -r "$SOURCE" ]
    then echo -e "Error: Please indicate a valid backup source\n"
    print_help
    exit 0
fi

# Check if TARGET exists, are writable and readable
if [ ! -e "$TARGET"  -o ! -r "$TARGET" -o ! -w "$TARGET" ]
    then echo "$TARGET_ROOT could not be read or written"
    exit 0
fi

eval "rsync -aAxXH --delete $SOURCE $TARGET --exclude=$EXCLUDE"
