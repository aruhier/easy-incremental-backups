#!/bin/bash
#
# Copyright (c) 2014 RUHIER Anthony
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
# * this list of conditions and the following disclaimer.  Redistributions in
# * binary form must reproduce the above copyright notice, this list of
# * conditions and the following disclaimer in the documentation and/or other
# * materials provided with the distribution.  Neither the name of the
# * copyright holder nor the names of its contributors may be used to endorse
# * or promote products derived from this software without specific prior
# * written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
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
SOURCE=$1
if [ ! -e "$SOURCE" -o ! -r "$SOURCE" ]
    then echo -e "Error: Please indicate a valid backup source\n"
    print_help
    exit 0
fi

# Checks if SOURCE ends with a '/'
i=$((${#SOURCE}-1))
last_char=${SOURCE:$i:1}
if [ "$last_char" != "/" ]
    then SOURCE=$SOURCE"/"
fi

# Check if TARGET exists, are writable and readable
if [ ! -e "$TARGET"  -o ! -r "$TARGET" -o ! -w "$TARGET" ]
    then echo "$TARGET_ROOT could not be read or written"
    exit 0
fi

rsync_line="rsync -aAxXH --delete $SOURCE $TARGET --exclude=$EXCLUDE"
rsync_line="$rsync_line --exclude="$BACKUPS_BASE_DIR""
eval "$rsync_line"
