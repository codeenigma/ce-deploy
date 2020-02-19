# ansible-deploy
<!--TOC-->
## [Install](install/README.md)

## [Docker](install/README.md#docker)
## [ansible-provision](install/README.md#ansible-provision)
## [Manual install](install/README.md#manual-install)
## [Usage](scripts/README.md)
## [Roles](roles/README.md)
### ["Meta"](roles/_meta/README.md)
Roles that bundles other individual roles together for tackling common use cases.
### [Database backup step.](roles/database_backup/README.md)
### [A Collection of cron-related tasks.](roles/cron/README.md)
By defaults those are run as the "deploy" user.

### [Code deployment](roles/code/README.md)
Roles managing the codebase: deployment, symlinks, composer steps, ...
### [CLI Tools](roles/cli/README.md)
Roles to install app-specific cli tool and utilities (Drush, ...)
## [Contribute](contribute/README.md)
<!--ENDTOC-->
