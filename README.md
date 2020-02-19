# ansible-deploy
A set of Ansible roles and wrapper scripts to deploy (web) applications.
## Overview
The "stack" from this repo is to be installed on a "deploy" server/runner, to be used in conjonction with a CI/CD tool (Jenkins, Gitlab, Travis, ...).
The "targets" for the deployments need to be accessible through SSH for Ansible to reach them.
<!--TOC-->
## [Install](install/README.md)
The stack only gets tested on Debian Buster, but should run on any Linux distribution, as long as Ansible >=2.9 is present.
## [Manual install](install/README.md#manual-install)
## [ansible-provision](install/README.md#ansible-provision)
## [Docker](install/README.md#docker)
## [Usage](scripts/README.md)
While you can re-use/fork roles or call playbooks directly from your deployment tool, it is recommended to use the provided wrapper scripts, as they will take care of setting up the needed environments.
## [Bundle script](scripts/README.md#bundle-script)
## [Individual scripts](scripts/README.md#individual-scripts)
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

## [Documentation](contribute/README.md#documentation)
<!--ENDTOC-->
