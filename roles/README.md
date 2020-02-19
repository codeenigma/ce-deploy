# Roles
<!--TOC-->
### [Database backup step.](sync/database_sync/README.md)
## ["Meta"](_meta/README.md)
Roles that bundles other individual roles together for tackling common use cases.
### [Drupal 8](_meta/deploy-drupal8/README.md)
Role for deploying single Drupal 8 instances, or multisites with a single database.
## [Database backup step.](database_backup/README.md)
## [A Collection of cron-related tasks.](cron/README.md)
By defaults those are run as the "deploy" user.

## [Database backup tasks.](cron/README.md#database-backup-tasks)
## [Code deployment](code/README.md)
Roles managing the codebase: deployment, symlinks, composer steps, ...
### [Deploy](code/deploy_code/README.md)
Step that deploys the codebase.
### [Config](code/config_generate/README.md)
Generates config files and handles sensitive variables.
### [Composer](code/composer/README.md)
Performs a composer install on a freshly deployed codebase.
## [CLI Tools](cli/README.md)
Roles to install app-specific cli tool and utilities (Drush, ...)
### [Drush](cli/drush/README.md)
Installs the `drush` command-line tool for the deploy user.
<!--ENDTOC-->
