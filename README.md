Easy incremental backup with rsync
==================================

Rsync is a powerful software to do some backups of your system, and like the
Apple Time Machine, it can do incremental backups to avoid using unnecessary
space.

So rsync is a great tool to do backups, but it needs some additional features
to make it really cool for system backups, and that the goal of these scripts.

Backup
------

Backups are made with the `backup-full-system.sh` script.It sorts all your
backups in this architecture :
backups_dir/year/month/day-month-year-hour:minute:second/.<br>
A symbolic link is created at the backups dir root, named `current_backup`,
which points on the last backup.<br>
It calls the `delete-old-backups.sh` to clean your old backups. See the
appropriate section for more informations.

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

`restore-full-system.sh BACKUP_DIR`, where `BACKUP_DIR` is the path of the
backup you want to restore (not to confound with the `BACKUPS_BASE_DIR` you
have set in the configuration file).

Use the option `-h` to print the help.

Configuration
-------------

Copy the `easy-incremental-backups.conf.default` configuration file as
`easy-incremental-backups.conf` and modify it for your setup.

**Do not edit directly this file, always make a copy before, it will avoid some
conflits with git if you pull from this repository**
