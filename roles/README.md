# Roles
Ansible roles and group of roles that constitute the deploy stack.
<!--TOC-->
## [Sync roles](sync/README.md)
Roles that sync data/assets between environments.
### [Database sync](sync/database_sync/README.md)
Roles that sync databases between environments.
## ["Meta"](_meta/README.md)
Roles that bundles other individual roles together for tackling common use cases.
### [Drupal 8](_meta/deploy-drupal8/README.md)
Role for deploying single Drupal 8 instances, or multisites with a single database.
## [Database backup step.](database_backup/README.md)
## [Cron](cron/README.md)
Roles to generate cron entries.
### [Database backup cron task](cron/cron_database_backup/README.md)
Ensure regular local backups of databases.
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
