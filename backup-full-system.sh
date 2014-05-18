#!/bin/bash
#
# Backup full system with rsync
# By Anthony25

#################
# CONFIGURATION #
#################

# Set the following constants depending on your configuration.

# TARGET_ROOT is the backup directory
TARGET_ROOT='/mnt/sda1/Backup'

# Let SOURCE at "/*" if you want to do a backup of all the system. Rsync is
# launched with the "-x" option, so it will stay in the "/" filesystem. If you
# have separated partitions, like home directory, add "/home to SOURCE"
SOURCE='/'

# EXCLUDE is the ignore list. Rsync is launched with the "-x" option, so it
# mights not fell into a loop (like in doing a backup of the disk where the
# backup is stored), but I usually add it in precaution
EXCLUDE='{/dev/*,/proc/*,/sys/*,/tmp/*,/run/*,/mnt/*,/media/*,/lost+found,'
EXCLUDE=$EXCLUDE'/home/*/.gvfs,/srv/ftp/*/*,/srv/nfs/*/*,/var/cache/pacman/*}'

#################

# TARGET_ROOT_EXTEND : class your backups by year and months
TARGET_ROOT_EXTEND="$TARGET_ROOT/$(date '+%Y')/$(date '+%m')"
CHANGELOG_ROOT="$TARGET_ROOT/changelog/$(date '+%Y')/$(date '+%m')"

# TARGET_NAME is the backup directory name
TARGET_NAME="$(date '+%d-%m-%Y-%T')"

TARGET="$TARGET_ROOT_EXTEND/$TARGET_NAME"
CHANGELOG="$CHANGELOG_ROOT/${TARGET_NAME}.txt"

SCRIPT_DIR="$( cd "$( dirname "$0"  )" && pwd  )"


interactive_changelog()
{
    if [ ! -d "$CHANGELOG_ROOT" ]
        then mkdir -p "$CHANGELOG_ROOT"
    fi

    echo -e "\n    $(date '+%d/%m/%Y')\n\n" > "$CHANGELOG"
    eval "$EDITOR" "$CHANGELOG"

    if [ "$(cat $CHANGELOG)" = "$(echo -e "\n    $(date '+%d/%m/%Y')\n\n")" ]
        then rm "$CHANGELOG"
    fi
}

print_help()
{
    echo -e "Full system backups, sorted by date.\n"
    echo "Options:"
    echo "    -h: Print help"
    echo "    -i: Interactive changelog"
    echo "    -o FILE: Log the output in FILE"
    exit 0
}


while getopts "ho:i" OPTION
do
    case $OPTION in
        h)
            print_help
            ;;
        o)
            exec >> "$2"
            ;;
        i)
            INTERACTIVE_CHANGELOG=1
            ;;
        ?)
            print_help
            ;;
    esac
done

# Check if SOURCE or TARGET exists, are writable and readable
if [ ! -e $TARGET_ROOT  -o ! -r $TARGET_ROOT -o ! -w $TARGET_ROOT ]
    then echo "$TARGET_ROOT could not be read or written"
    exit 0
fi

echo "$(date "+%b %e %T") : Backup started"

# Delete old backups
eval "$SCRIPT_DIR/delete-old-backups.sh"

if [ "$INTERACTIVE_CHANGELOG" = "1" ]
    then interactive_changelog
fi

if [ ! -d $TARGET_ROOT_EXTEND ]
    then mkdir -p "$TARGET_ROOT_EXTEND"
fi

# If the symlink current exists, it makes an incremental backup, otherwise it creates the first backup
last="$TARGET_ROOT/current_backup"

if [ -L $last ]
    then eval "rsync -aAxXH --delete --link-dest=$last $SOURCE $TARGET --exclude=$EXCLUDE"
    rm -f $last

else
    eval "rsync -aAxXH --delete "$SOURCE" "$TARGET" --exclude=$EXCLUDE"
fi

cd $TARGET_ROOT
ln -s "$(date '+%Y')/$(date '+%m')/$TARGET_NAME" current_backup

echo "$(date "+%b %e %T") : Backup finished"
