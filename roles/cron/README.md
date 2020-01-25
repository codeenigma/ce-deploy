# A Collection of cron-related tasks.
By defaults those are run as the "deploy" user.

## Database backup tasks.
The collection of cron_database_backup tasks ensure regular backups of the dbs.
Not that they rely on being called after the "build" database backup roles and can't
be used independantly.
Use the standard cron module in your playbook if you need something more custom.