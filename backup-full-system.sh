#!/bin/bash
#
# Backup full system with rsync
# By Anthony25

SCRIPT_DIR="$( cd "$( dirname "$0"  )" && pwd  )"

# Change this line if the configuration file is not in the same directory that
# this script
CONFIGURATION_FILE="$SCRIPT_DIR"/easy-incremental-backups.conf

# Use the configuration file
source "$CONFIGURATION_FILE"
TARGET_ROOT="$BACKUPS_BASE_DIR"
SOURCE="$PATH_TO_BACKUP"
EXCLUDE="$EXCLUDE"

# TARGET_ROOT_EXTEND : class your backups by year and months
TARGET_ROOT_EXTEND="$TARGET_ROOT/$(date '+%Y')/$(date '+%m')"
CHANGELOG_ROOT="$TARGET_ROOT/changelog/$(date '+%Y')/$(date '+%m')"

# TARGET_NAME is the backup directory name
TARGET_NAME="$(date '+%d-%m-%Y-%T')"

TARGET="$TARGET_ROOT_EXTEND/$TARGET_NAME"
CHANGELOG="$CHANGELOG_ROOT/${TARGET_NAME}.txt"


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

# Check if the configuration file exists
if [ ! -e "$CONFIGURATION_FILE" -o ! -r "$CONFIGURATION_FILE" ]
    then echo -e "ERROR: Configuration file not found\n"
    print_help
    exit 1
fi

# Check if SOURCE or TARGET exists, are writable and readable
if [ ! -e "$TARGET_ROOT"  -o ! -r "$TARGET_ROOT" -o ! -w "$TARGET_ROOT" ]
    then echo "$TARGET_ROOT could not be read or written"
    exit 2
fi

echo "$(date "+%b %e %T") : Backup started"

# Delete old backups
eval ""$SCRIPT_DIR"/delete-old-backups.sh"

if [ "$INTERACTIVE_CHANGELOG" = "1" ]
    then interactive_changelog
fi

if [ ! -d "$TARGET_ROOT_EXTEND" ]
    then mkdir -p "$TARGET_ROOT_EXTEND"
fi

# If the symlink current exists, it makes an incremental backup, otherwise
# it creates the first backup
last="$TARGET_ROOT/current_backup"

if [ -L $last ]
    then rsync_line="rsync -aAxXH --delete --link-dest=$last $SOURCE "$TARGET""
    rsync_line="$rsync_line --exclude=$EXCLUDE"
    eval "$rsync_line"
    rm -f $last

else
    eval "rsync -aAxXH --delete "$SOURCE" "$TARGET" --exclude=$EXCLUDE"
fi

cd $TARGET_ROOT
ln -s "$(date '+%Y')/$(date '+%m')/$TARGET_NAME" current_backup

echo "$(date "+%b %e %T") : Backup finished"
