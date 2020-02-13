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
  ANSIBLE_DEFAULT_EXTRA_VARS="{local_build_path: $BUILD_WORKSPACE, build_number: $CURRENT_BUILD_NUMBER, previous_known_build_number: $PREVIOUS_BUILD_NUMBER}"
}

# Fetch previous build number from track file.
get_previous_build_number(){
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
}

# # Make sure we exit cleanly.
# trap cleanup_exit EXIT INT TERM QUIT HUP

# # Base settings. We can't use mktemp directly, Ansible gets confused when run from /tmp.
# BUILD_DIR_BASE="$OWN_DIR/build"
# if [ ! -d "$BUILD_DIR_BASE" ]; then
#   mkdir "$BUILD_DIR_BASE"
# fi
# BUILD_DIR_TRACK="$BUILD_DIR_BASE/track"
# if [ ! -d "$BUILD_DIR_TRACK" ]; then
#   mkdir "$BUILD_DIR_TRACK"
# fi
# BUILD_DIR=$(mktemp -d -p "$BUILD_DIR_BASE")

# # Parse options and make sure everything's up to date.
# parse_options "$@"

# # Check we have enough arguments.
# if [ -z "$TARGET_DEPLOY_REPO" ] || [ -z "$TARGET_DEPLOY_PLAYBOOK" ] || [ -z "$TARGET_DEPLOY_BRANCH" ] || [ -z "$BUILD_NUMBER" ]; then
#  usage
#  exit 1
# fi

# # Check if we know about previous builds.
# BUILD_FILE_TRACK="$BUILD_DIR_TRACK/$(echo "$TARGET_DEPLOY_REPO-$TARGET_DEPLOY_BRANCH-$TARGET_DEPLOY_PLAYBOOK" | tr / -)"
# if [ -f "$BUILD_FILE_TRACK" ]; then
#   PREVIOUS_BUILD_NUMBER=$(cat "$BUILD_FILE_TRACK")
# fi

# TARGET_PLAYBOOK_PATH="$BUILD_DIR/$TARGET_DEPLOY_PLAYBOOK"
# ANSIBLE_DEFAULT_EXTRA_VARS="{local_build_path: $BUILD_DIR, build_number: $BUILD_NUMBER, target_playbook: $TARGET_PLAYBOOK_PATH, previous_known_build_number: $PREVIOUS_BUILD_NUMBER}"

# # Clone target repo.
# repo_target_clone
# # Trigger actual provisioning. From this point on, we revert in case of failure.
# ANSIBLE_BUILD_RESULT=1
# /usr/bin/ansible-playbook --verbose "$TARGET_PLAYBOOK_PATH"  --extra-vars "{deploy_operation: deploy}" --extra-vars "$ANSIBLE_DEFAULT_EXTRA_VARS" --extra-vars "$ANSIBLE_EXTRA_VARS"
# ANSIBLE_BUILD_RESULT=$?
# # Keep track of successful build.
# # This means we loose track of it when changing repo,
# # but avoids coming with an additional parameter.
# # The Ansible side will correct this using the live symlink,
# # so should not be an issue anyway.
# if [ -n "$ANSIBLE_BUILD_RESULT" ] && [ "$ANSIBLE_BUILD_RESULT" = 0 ]; then
#   echo "$BUILD_NUMBER" > "$BUILD_FILE_TRACK"
#   # Clean up the builds. Note that we won't revert if that fail, as the "build" itself is successful.
#   # We still exit with an error, so it gets flagged.
#   /usr/bin/ansible-playbook --verbose "$TARGET_PLAYBOOK_PATH"  --extra-vars "{deploy_operation: cleanup}" --extra-vars "$ANSIBLE_DEFAULT_EXTRA_VARS" --extra-vars "$ANSIBLE_EXTRA_VARS"
#   exit 0
# fi
# # Failed.
# exit 1
