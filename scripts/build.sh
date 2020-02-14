#!/bin/sh

set -eu

usage(){
  echo 'build.sh [OPTIONS] --repo <git repo to deploy> --branch <branch to deploy> --playbook <path to playbook> --build-number < incremental build number>'
  echo 'Deploy an application, with revert and cleanup steps.'
  echo ''
  echo 'Mandatory arguments:'
  echo '--repo: Path to a remote git repo. The "deploy" user must have read access to it.'
  echo '--branch: The branch to deploy.'
  echo '--playbook: Relative path to an ansible playbook within the repo.'
  echo '--build-number: an incremental build number'
  echo ''
  echo 'Available options:'
  echo '--ansible-extra-vars: Variable to pass as --extra-vars arguments to ansible-playbook. Make sure to escape them properly.'
  echo '--workspace: a local existing clone of the repo/branch (if your deployment tool already has one). This will skip the cloning/fetching of the repo.'
  echo '--previous-stable-build-number: an incremental build number'
}

# Ensure we revert and remove build artefacts.
revert_exit(){
  set +e
  # Revert build.
  if [ "$ANSIBLE_BUILD_RESULT" != 0 ]; then
    ansible_play 'revert'
  fi
  # Cleanup build directory.
  if [ "$BUILD_WORKSPACE_TYPE" != 'external' ]; then
    cleanup_build_workspace
  fi
}

# Define initial success/failure state. 
# We start we success, to avoid trying to revert
# the build to early in the process.
ANSIBLE_BUILD_RESULT=0
# Marker to clean up the workspace if it's ours.
BUILD_WORKSPACE_TYPE="external"

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

# Always revert if anything fails.
trap revert_exit EXIT INT TERM QUIT HUP

# If we have no workspace, create it and clone the repo.
if [ -z "$BUILD_WORKSPACE" ]; then
  BUILD_WORKSPACE_TYPE='local'
  get_build_workspace
  repo_target_clone
fi

# If we have no enforced last known good number, fetch it.
if [ -z "$PREVIOUS_BUILD_NUMBER" ]; then
  get_previous_build_number
fi

# Get Ansible defaults.
get_ansible_defaults_vars

# From this point on, we want to trigger the "revert".
ANSIBLE_BUILD_RESULT=1
# Trigger deploy.
ansible_play 'deploy'
ANSIBLE_BUILD_RESULT=$?

# Keep track of successful build.
if [ -n "$ANSIBLE_BUILD_RESULT" ] && [ "$ANSIBLE_BUILD_RESULT" = 0 ]; then
  set_previous_build_number "$CURRENT_BUILD_NUMBER"
  # Clean up the builds. Note that we won't revert if that fail, as the "build" itself is successful.
  # We still exit with an error, so it gets flagged.
  ansible_play 'cleanup'
  exit 0
fi
# Failed somehow. Normally unreachable in strict mode.
exit 1