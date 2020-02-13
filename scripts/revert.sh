#!/bin/sh

set -eu

usage(){
  echo 'revert.sh [OPTIONS] --repo <git repo to deploy> --branch <branch to deploy> --playbook <path to playbook> --buildnumber < incremental build number>'
  echo 'Revert deployment for an application.'
  echo ''
  echo 'Mandatory arguments:'
  echo '--repo: Path to a remote git repo. The "deploy" user must have read access to it.'
  echo '--branch: The branch to deploy.'
  echo '--playbook: Relative path to an ansible playbook within the repo.'
  echo '--buildnumber: an incremental build number'
  echo ''
  echo 'Available options:'
  echo '--ansible-extra-vars: Variable to pass as --extra-vars arguments to ansible-playbook. Make sure to escape them properly.'
  echo '--workspace: a local existing clone of the repo/branch (if your deployment tool already has one). This will skip the cloning/fetching of the repo.'
  echo '--previous-stable-build-number: an incremental build number'
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

# Check we have enough arguments.
if [ -z "$TARGET_DEPLOY_REPO" ] || [ -z "$TARGET_DEPLOY_PLAYBOOK" ] || [ -z "$TARGET_DEPLOY_BRANCH" ] || [ -z "$CURRENT_BUILD_NUMBER" ]; then
 usage
 exit 1
fi

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
ansible_play 'revert'