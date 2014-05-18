#!/bin/bash
#
# Print the backups to delete
# One backup by day (except for today) for the last 30 days, before it's one
# backup by month.
# By Anthony25

SCRIPT_DIR="$( cd "$( dirname "$0"  )" && pwd  )"

# Change this line if the configuration file is not in the same directory that
# this script
CONFIGURATION_FILE="$SCRIPT_DIR"/easy-incremental-backups.conf

# Use the configuration file
source "$CONFIGURATION_FILE"
TARGET_ROOT="$BACKUPS_BASE_DIR"


get_day()
{
    backup="$1"
    day=${backup:0:2}
    echo $day
}

list_months()
{
    year=$1
    months=$(ls "$TARGET_ROOT/$year" | grep -E ^[0-9]{1\,2}$ 2>/dev/null)
    echo $months
}

list_years()
{
    echo $(ls "$TARGET_ROOT" | grep -E ^[0-9]{4}$ 2>/dev/null)
}

# Not more than one by day for the month sent in parameter
nmto_by_day()
{
    year=$1
    month=$2

    backups=$(ls "$TARGET_ROOT/$year/$month")
    temp_day=""
    temp_backup=""

    for backup in $backups
    do
        day="$(get_day "$backup")"
        if [ "$temp_day" != "" -a "$day" == "$temp_day" -a \
             "$day" != "$(date +%d)" ]
            then echo "$TARGET_ROOT/$year/$month/$temp_backup"
        fi
        temp_day="$day"
        temp_backup="$backup"
    done
}

# One backup in the month, keep only the last one
clean_all_except_last_one()
{
    year=$1
    month=$2
    backups=$(ls -d "$TARGET_ROOT/$year/$month/"* 2>/dev/null)

    backup_2_delete=$(echo "$backups" | head -n -1)
    echo "$backup_2_delete"
}

# Last 30 days in the middle of the month : Last 30 days rarely are in an
# entire month. Delete all backups of the month until the one 30 days ago.
last_30_days_imo_month()
{
    year=$1
    month=$2
    day=$3

    backups=$(ls -d "$TARGET_ROOT/$year/$month/"[0-${day:0:1}][0-${day:1:2}]*\
              2>/dev/null)
    echo "$backups"
}

dirs_to_delete()
{
    y_30da="$(date --date="30 days ago" +%Y)"
    m_30da="$(date --date="30 days ago" +%m)"
    d_30da="$(date --date="30 days ago" +%d)"

    for year in $(list_years)
    do
        months=$(list_months $year)
        for month in $months
        do
            if [ "$month" -lt "$m_30da" -o "$year" -lt "$y_30da" ]
                then echo "$(clean_all_except_last_one $year $month)"
            elif [ "$month" -eq "$m_30da" ]
                then echo "$(last_30_days_imo_month $year $month $d_30da)"
                echo "$(nmto_by_day $year $month)"
            else
                echo "$(nmto_by_day $year $month)"
            fi
        done
    done
}


# Check if the configuration file exists
if [ ! -e "$CONFIGURATION_FILE" -o ! -r "$CONFIGURATION_FILE" ]
    then echo -e "ERROR: Configuration file not found\n"
    exit 1
fi

dirs_to_delete=$(dirs_to_delete)

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for dir in $dirs_to_delete
do
    rm -Rf "$dir"
done
IFS=$SAVEIFS
