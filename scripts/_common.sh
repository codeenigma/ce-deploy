#!/bin/sh

set -eu

# Default variables.
TARGET_DEPLOY_REPO=""
TARGET_DEPLOY_PLAYBOOK=""
TARGET_DEPLOY_BRANCH=""
PREVIOUS_BUILD_NUMBER=""
CURRENT_BUILD_NUMBER=""
ANSIBLE_EXTRA_VARS=""
ANSIBLE_DEFAULT_EXTRA_VARS=""
BUILD_WORKSPACE=""
BUILD_TRACK_FILE=""
# Parse options arguments.
parse_options(){
  while [ "${1:-}" ]; do
    case "$1" in
      "--repo")
          shift
          TARGET_DEPLOY_REPO="$1"
        ;;
      "--branch")
          shift
          TARGET_DEPLOY_BRANCH="$1"
        ;;
      "--playbook")
          shift
          TARGET_DEPLOY_PLAYBOOK="$1"
        ;;
      "--build-number")
          shift
          CURRENT_BUILD_NUMBER="$1"
        ;;
      "--ansible-extra-vars")
          shift
          ANSIBLE_EXTRA_VARS="$1"
        ;;
      "--workspace")
          shift
          BUILD_WORKSPACE="$1"
        ;;
      "--previous-stable-build-number")
          shift
          PREVIOUS_BUILD_NUMBER="$1"
        ;;
        *)
        usage
        exit 1
        ;;
    esac
    shift
  done
}

# Path to the track file for given build.
get_build_track_file(){
  BUILD_TRACK_DIR="$OWN_DIR/track"
  if [ ! -d "$BUILD_TRACK_DIR" ]; then
    mkdir "$BUILD_TRACK_DIR"
  fi
  BUILD_TRACK_FILE="$BUILD_TRACK_DIR/$(echo "$TARGET_DEPLOY_REPO-$TARGET_DEPLOY_BRANCH-$TARGET_DEPLOY_PLAYBOOK" | tr / -)"
}

# Compute defaults variables.
get_build_workspace(){
  BUILD_WORKSPACE_BASE="$OWN_DIR/build"
  if [ ! -d "$BUILD_WORKSPACE_BASE" ]; then
    mkdir "$BUILD_WORKSPACE_BASE"
  fi
  BUILD_WORKSPACE=$(mktemp -d -p "$BUILD_WORKSPACE_BASE")
}

# Common extra-vars to pass to Ansible.
get_ansible_defaults_vars(){
  ANSIBLE_DEFAULT_EXTRA_VARS="{ansible_deploy_scripts_local_path: $OWN_DIR, local_build_path: $BUILD_WORKSPACE, build_number: $CURRENT_BUILD_NUMBER, previous_known_build_number: $PREVIOUS_BUILD_NUMBER}"
}

# Fetch previous build number from track file.
get_previous_build_number(){
  get_build_track_filegi
  PREVIOUS_BUILD_NUMBER=0
  if [ -f "$BUILD_TRACK_FILE" ]; then
    PREVIOUS_BUILD_NUMBER=$(cat "$BUILD_TRACK_FILE")
  fi
}

# Set previous build number to track file.
# $1 (string)
# Successful build number to store.
set_previous_build_number(){
  echo "$1" > "$BUILD_TRACK_FILE"
}

# Clone our target repo.
repo_target_clone(){
  git clone "$TARGET_DEPLOY_REPO" "$BUILD_WORKSPACE" --depth 1 --branch "$TARGET_DEPLOY_BRANCH"
}

# Remove build directory.
cleanup_build_workspace(){
  if [ -n "$BUILD_WORKSPACE" ] && [ -d "$BUILD_WORKSPACE" ]; then
    rm -rf "$BUILD_WORKSPACE"
  fi
}
# Trigger actual Ansible job.
# $1 (string)
# Operation to perform.
# - deploy
# - revert
# - cleanup
ansible_play(){
  /usr/bin/ansible-playbook --verbose "$BUILD_WORKSPACE/$TARGET_DEPLOY_PLAYBOOK"  --extra-vars "{deploy_operation: $1}" --extra-vars "$ANSIBLE_DEFAULT_EXTRA_VARS" --extra-vars "$ANSIBLE_EXTRA_VARS"
  return $?
}