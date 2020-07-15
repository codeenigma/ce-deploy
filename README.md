# ce-deploy
A set of Ansible roles and wrapper scripts to deploy (web) applications.
## Overview
The "stack" from this repo is to be installed on a "deploy" server/runner, to be used in conjonction with a CI/CD tool (Jenkins, Gitlab, Travis, ...).
It allows the deploy steps for a given app to be easily customizable at will, and to be stored alongside the codebase of the project.
When triggered from a deployment tool, the stack will clone the codebase and "play" a given deploy playbook from there.

<!--TOC-->
## [Install](install/README.md)
The stack only gets tested on Debian Buster, but should run on any Linux distribution, as long as Ansible >=2.9 is present.
You can install either:
- through [ce-provision](https://github.com/codeenigma/ce-provision)
- manually by running a local playbook
- with Docker (soon)

### [Install with ce-provision](install/README.md#install-with-ce-provision)
### [Install manually](install/README.md#install-manually)
### [Install with Docker](install/README.md#install-with-docker)
### [Configuration](install/README.md#configuration)
## [Usage](scripts/README.md)
While you can re-use/fork roles or call playbooks directly from your deployment tool, it is recommended to use the provided wrapper scripts, as they will take care of setting up the needed environments.
### [Deploy with the "build" script](scripts/README.md#deploy-with-the-build-script)
### [Deploy with individual steps](scripts/README.md#deploy-with-individual-steps)
## [Roles](roles/README.md)
Ansible roles and group of roles that constitute the deploy stack.
### [Sync roles](roles/sync/README.md)
Roles that sync data/assets between environments.
### ["Meta"](roles/_meta/README.md)
Roles that bundles other individual roles together for tackling common use cases.
### [Data backups](roles/database_backup/README.md)
Generate backups for each build.
### [Cron](roles/cron/README.md)
Roles to generate cron entries.
### [Code deployment](roles/code/README.md)
Roles managing the codebase: deployment, symlinks, composer steps, ...
### [CLI Tools](roles/cli/README.md)
Roles to install app-specific cli tool and utilities (Drush, ...)
## [Contribute](contribute/README.md)

### [Documentation](contribute/README.md#documentation)
<!--ENDTOC-->
