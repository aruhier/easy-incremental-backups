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
TARGET="$PATH_TO_BACKUP"
EXCLUDE="$EXCLUDE"


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

# Check if the configuration file exists
if [ ! -e "$CONFIGURATION_FILE" -o ! -r "$CONFIGURATION_FILE" ]
    then echo -e "ERROR: Configuration file not found\n"
    print_help
    exit 1
fi

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
