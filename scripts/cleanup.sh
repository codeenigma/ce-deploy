#!/bin/sh

set -eu

usage(){
  echo 'cleanup.sh [OPTIONS] --repo <git repo to deploy> --branch <branch to deploy> --playbook <path to playbook> --build-number < incremental build number> --build-id <custom identifier>'
  echo 'cleanup.sh [OPTIONS] --workspace <local path> --playbook <path to playbook> --build-number < incremental build number>  --build-id <custom identifier>'
  echo 'Cleanup old artefacts for an application.'
  echo ''
  echo 'Mandatory arguments:'
  echo '--build-number: an incremental build number'
  echo '--playbook: Relative path to an ansible playbook within the workspace/repository.'
  echo '--build-id: A custom identifier used to "track" successful deployments.'
  echo ''
  echo 'You must also pass either:'
  echo '--workspace: a local workspace (if your deployment tool already has one). This will skip the cloning/fetching of the repo.'
  echo 'or both:'
  echo '--repo: Path to a remote git repo. The "deploy" user must have read access to it.'
  echo '--branch: The branch to deploy.'
  echo ''
  echo 'Available options:'
  echo '--ansible-extra-vars: Variable to pass as --extra-vars arguments to ansible-playbook. Make sure to escape them properly.'
  echo '--ansible-path: Pass the path to the directory containing the Ansible binaries if you are not using the version of Ansible in PATH.'
  echo '--python-interpreter: When using Python virtual environments Ansible may not correctly determine the Python interpreter, use this to set it manually.'
  echo '--previous-stable-build-number: an incremental build number that '
  echo '--dry-run: Do not perform any action but run the playbooks in --check mode.'
  echo '--verbose: Detailled informations. This can potentially leak sensitive information in the output'
  echo '--own-branch: Branch to use for the main stack repository'
  echo '--config-branch: Branch to use for the main stack config repository'
  echo '--boto-profile: Name of a profile to export as AWS_PROFILE before calling Ansible'
}

# Common processing.
OWN_DIR=$(dirname "$0")
cd "$OWN_DIR" || exit 1
OWN_DIR=$(git rev-parse --show-toplevel)
cd "$OWN_DIR" || exit 1
OWN_DIR=$(pwd -P)

# shellcheck source=./_common.sh
. "$OWN_DIR/scripts/_common.sh"

# Parse options.
parse_options "$@"

# Check we have mandatory arguments.
if [ -z "$TARGET_DEPLOY_PLAYBOOK" ] || [ -z "$CURRENT_BUILD_NUMBER" ] || [ -z "$BUILD_ID" ]; then
 usage
 exit 1
fi

# Check we have a workspace or a repo.
if [ -z "$BUILD_WORKSPACE" ]; then
  if [ -z "$TARGET_DEPLOY_REPO" ] || [ -z "$TARGET_DEPLOY_BRANCH" ]; then
    usage
    exit 1
  fi
fi

trap cleanup_build_tmp_dir EXIT INT TERM QUIT HUP

# If we have no workspace, create it and clone the repo.
if [ -z "$BUILD_WORKSPACE" ]; then
  trap cleanup_build_workspace EXIT INT TERM QUIT HUP
  get_build_workspace
  repo_target_clone
fi

# If we have no enforced last known good number, fetch it.
if [ -z "$PREVIOUS_BUILD_NUMBER" ]; then
  get_previous_build_number
fi

# Get Ansible defaults.
get_ansible_defaults_vars

# Trigger deploy.
ansible_play 'cleanup'