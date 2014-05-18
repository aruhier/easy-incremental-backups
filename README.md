Easy incremental backup with rsync
==================================

Rsync is a powerful software to do some backups of your system, and like the
Apple Time Machine, it can do incremental backups to avoid using unnecessary
space.

So rsync is a great tool to do backups, but it needs some additional features
to make it really cool for system backups, and that the goal of those scripts.

Backup
------

Backups are made with the `backup-full-system.sh` script.It sorts all your
backups in this architecture :
backups_dir/year/month/day-month-year-hour:minute:second/.
A symbolic link is created at the backups dir root, named `current_backup`,
which points on the last backup.
It calls the `delete-old-backups.sh` to clean your old backups. See the
appropriate section for more informations

If you want to use this script in a cronjob (for example), you might want to
log everything, to see if there an error happened during the backup or
something.  You can use the `-o LOGFILE` option, where `LOGFILE` is the file
where you want to log all the output.

If you want to start a backup manually, maybe you want to write a changelog, so
just launch this script with the `-i` option. It uses your EDITOR environment
variable, so if it doesn't open the text editor you are using to use, please
set this variable in your shell configuration (.bashrc, .zshrc etc...). It will
save the changelog in a changelog directory, in the backups dir root.

Use the option `-h` to print the help.

Delete old backups
------------------

No surprise again, the script `delete-old-backups.sh` will... delete old
backups ! It will keep all the backups for current day, one backup by day for
the last 30 days and before it's one backup by month (for the moment, maybe I
will add the "one backup by year" and doing it more customizable). For each
case, it will keep the last backup (so the last backup of the day or month).


Restore
-------

The script `restore-full-system.sh` is a not user friendly for the moment.
You have to modify the "SOURCE" constant for the backup path you want to
restore.

Configuration
-------------

Configurations are note synced between the scripts (yet), so you have to modify
the constants in each scripts to configure it correctly.
**ATTENTION**: If you are doing a backup, do not forget to configure the
`delete-old-backups.sh` script to delete the old scripts. It can be dangerous
to let it unconfigured, as it can delete some files in thinking it's backups
(if you are really unlucky).

Just modify the *CONFIGURATION* section of each script, each constant is
documented.
