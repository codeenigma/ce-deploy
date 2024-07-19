#!/bin/sh

set -eu

usage(){
  echo 'build.sh [OPTIONS] --repo <git repo to deploy> --branch <branch to deploy> --playbook <path to playbook> --build-number <incremental build number> --build-id <custom identifier>'
  echo 'build.sh [OPTIONS] --workspace <local path> --playbook <path to playbook> --build-number <incremental build number> --build-id <custom identifier>'
  echo 'Deploy an application, with revert and cleanup steps.'
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
  echo '--host: Valid Ansible hostname, if you want to run a host check. Can also be a group name.'
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
  cleanup_build_tmp_dir
}

# Define initial success/failure state. 
# We start with success, to avoid trying to revert
# the build too early in the process.
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

# Always revert if anything fails.
trap revert_exit EXIT INT TERM QUIT HUP

# If we have no workspace, create it and clone the repo.
if [ -z "$BUILD_WORKSPACE" ]; then
  BUILD_WORKSPACE_TYPE='internal'
  get_build_workspace
  repo_target_clone
fi

# If we have no enforced last known good number, fetch it.
if [ -z "$PREVIOUS_BUILD_NUMBER" ]; then
  get_previous_build_number
fi

# Get Ansible defaults.
get_ansible_defaults_vars

# Optionally carry out a host check if --host is provided.
ansible_host_check
ANSIBLE_HOST_CHECK_RESULT=$?
# Exit early if host not found.
if [ -n "$ANSIBLE_HOST_CHECK_RESULT" ] && [ "$ANSIBLE_HOST_CHECK_RESULT" != 0 ]; then
  echo "ce-deploy failed to find the host. Aborting."
  exit 1
fi

# From this point on, we want to trigger the "revert" if anything fails.
ANSIBLE_BUILD_RESULT=1
# Trigger deploy.
ansible_play 'deploy'
ANSIBLE_BUILD_RESULT=$?

# Keep track of successful build.
if [ -n "$ANSIBLE_BUILD_RESULT" ] && [ "$ANSIBLE_BUILD_RESULT" = 0 ]; then
  set_previous_build_number "$CURRENT_BUILD_NUMBER"
  # Clean up the builds. Note that we won't revert if that fails, as the "build" itself is successful.
  # We still exit with an error, so it gets flagged.
  ansible_play 'cleanup'
  exit 0
fi
# Failed somehow. Normally unreachable in strict mode.
echo "Something went unexpectedly wrong with ce-deploy. Please file a bug report - https://github.com/codeenigma/ce-deploy/issues/new"
exit 1