# ce-deploy
A set of Ansible roles and wrapper scripts to deploy (web) applications.
## Overview
The "stack" from this repo is to be installed on a "deploy" server/runner, to be used in conjonction with a CI/CD tool (Jenkins, Gitlab, Travis, ...).
It allows the deploy steps for a given app to be easily customizable at will, and to be stored alongside the codebase of the project.
When triggered from a deployment tool, the stack will clone the codebase and "play" a given deploy playbook from there.

