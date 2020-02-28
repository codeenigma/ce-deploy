# "Meta"
Roles that bundles other individual roles together for tackling common use cases.
<!--TOC-->
## [Install](install/README.md)
The stack only gets tested on Debian Buster, but should run on any Linux distribution, as long as Ansible >=2.9 is present.
You can install either:
- through [ansible-provision](https://github.com/codeenigma/ansible-provision)
- manually by running a local playbook
- with Docker (soon)

## [Usage](scripts/README.md)
While you can re-use/fork roles or call playbooks directly from your deployment tool, it is recommended to use the provided wrapper scripts, as they will take care of setting up the needed environments.
## [Roles](roles/README.md)
Ansible roles and group of roles that constitute the deploy stack.
### [CLI Tools](roles/cli/README.md)
Roles to install app-specific cli tool and utilities (Drush, ...)
### [Code deployment](roles/code/README.md)
Roles managing the codebase: deployment, symlinks, composer steps, ...
### [Cron](roles/cron/README.md)
Roles to generate cron entries.
### [Data backups](roles/database_backup/README.md)
Generate backups for each build.
### ["Meta"](roles/meta/README.md)
Roles that bundles other individual roles together for tackling common use cases.
### [Sync roles](roles/sync/README.md)
Roles that sync data/assets between environments.
## [Contribute](contribute/README.md)

<!--ENDTOC-->
