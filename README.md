# ce-deploy

A set of Ansible roles and wrapper scripts to deploy (web) applications.

## Overview
The "stack" from this repo is to be installed on a "deploy" server/runner, to be used in conjonction with a CI/CD tool (Jenkins, Gitlab, Travis, ...).
It allows the deploy steps for a given app to be easily customisable and to be stored alongside the codebase of the project.
When triggered from a deployment tool, the stack will clone the codebase and "play" a given deploy playbook from there.

<!--TOC-->
## Install
The stack only gets tested on Debian Linux, but should run on any Linux distribution, as long as Ansible >=2.9 is present.
You can install either:

* [With ce-provision](install/README.md#install-with-ce-provision)
* [Manually by running a local playbook](install/README.md#install-manually)
* [With Docker (coming soon)](install/README.md#install-with-docker)

[More installation instructions can be found here.](install/README.md)

[Configuration options here.](install/README.md#configuration)

## Usage
While you can re-use/fork roles or call playbooks directly from your deployment tool, it is recommended to use the provided wrapper scripts, as they will take care of setting up the needed environments.

* [Deploy with the "build" script](scripts/README.md#deploy-with-the-build-script)
* [Deploy with individual steps](scripts/README.md#deploy-with-individual-steps)

## Roles
[Ansible roles and group of roles that constitute the deploy stack.](roles/README.md)

* [Sync roles](roles/sync/README.md) - roles that sync data/assets between environments.
* ["Meta"](roles/_meta/README.md) - roles that bundles other individual roles together for tackling common use cases.
* [Data backups](roles/database_backup/README.md) - generate backups for each build.
* [Cron](roles/cron/README.md) - roles to generate cron entries.
* [Code deployment](roles/code/README.md) - roles managing the codebase: deployment, symlinks, composer steps, ...
* [CLI Tools](roles/cli/README.md) - roles to install app-specific cli tool and utilities (Drush, cachetool, ...)

## Contribute
[Find out more about conrtibuting here.](contribute/README.md)
<!--ENDTOC-->
