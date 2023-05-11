#!/bin/sh

set -eu

export ANSIBLE_FORCE_COLOR=true
export ANSIBLE_CONFIG="$OWN_DIR/ansible.cfg"

# Default variables.
TARGET_DEPLOY_REPO=""
TARGET_DEPLOY_PLAYBOOK=""
TARGET_DEPLOY_BRANCH=""
TARGET_DEPLOY_HOST=""
PREVIOUS_BUILD_NUMBER=""
CURRENT_BUILD_NUMBER=""
ANSIBLE_EXTRA_VARS=""
ANSIBLE_DEFAULT_EXTRA_VARS=""
BUILD_WORKSPACE=""
BUILD_TRACK_FILE=""
BUILD_ID=""
BUILD_WORKSPACE_BASE="$OWN_DIR/build"
DRY_RUN="no"
VERBOSE="no"
BOTO_PROFILE=""
if [ ! -d "$BUILD_WORKSPACE_BASE" ]; then
    mkdir "$BUILD_WORKSPACE_BASE"
fi
BUILD_TMP_DIR=$(mktemp -d -p "$BUILD_WORKSPACE_BASE")
ANSIBLE_DATA_DIR="$OWN_DIR/data"
if [ ! -d "$ANSIBLE_DATA_DIR" ]; then
    mkdir "$ANSIBLE_DATA_DIR"
fi
BUILD_TRACK_DIR="$OWN_DIR/track"
if [ ! -d "$BUILD_TRACK_DIR" ]; then
  mkdir "$BUILD_TRACK_DIR"
fi
ANSIBLE_LOCATION=$(command -v ansible)
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
      "--host")
          shift
          TARGET_DEPLOY_HOST="$1"
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
      "--dry-run")
          DRY_RUN="yes"
        ;;
      "--verbose")
          VERBOSE="yes"
        ;;
      "--own-branch")
          shift
          git_checkout_own_dir "$1"
        ;;
      "--config-branch")
          shift
          git_checkout_config_dir "$1"
        ;;    
      "--boto-profile")
          shift
          BOTO_PROFILE="$1"
        ;;
      "--build-id")
          shift
          BUILD_ID="$1"
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
  BUILD_TRACK_FILE="$BUILD_TRACK_DIR/$BUILD_ID"
}

# Compute defaults variables.
get_build_workspace(){
  BUILD_WORKSPACE=$(mktemp -d -p "$BUILD_WORKSPACE_BASE")
}

# Common extra-vars to pass to Ansible.
get_ansible_defaults_vars(){
  ANSIBLE_DEFAULT_EXTRA_VARS="{_ce_deploy_base_dir: $OWN_DIR, _ce_deploy_build_dir: $BUILD_WORKSPACE, _ce_deploy_build_tmp_dir: $BUILD_TMP_DIR, _ce_deploy_data_dir: $ANSIBLE_DATA_DIR, _ce_deploy_ansible_location: $ANSIBLE_LOCATION, build_number: $CURRENT_BUILD_NUMBER, previous_known_build_number: $PREVIOUS_BUILD_NUMBER}"
}

# Fetch previous build number from track file.
get_previous_build_number(){
  get_build_track_file
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
  cleanup_build_tmp_dir
}
# Remove tmp directory.
cleanup_build_tmp_dir(){
  if [ -n "$BUILD_TMP_DIR" ] && [ -d "$BUILD_TMP_DIR" ]; then
    rm -rf "$BUILD_TMP_DIR"
  fi
}

# Call Ansible playbook to ensure host exists.
ansible_host_check(){
  if [ -n "$TARGET_DEPLOY_HOST" ]; then
    ANSIBLE_BIN=$(command -v ansible-playbook)
    ANSIBLE_CMD="$ANSIBLE_BIN $OWN_DIR/scripts/host-check.yml"
    if [ "$VERBOSE" = "yes" ]; then
      ANSIBLE_CMD="$ANSIBLE_CMD -vvvv"
    fi
    if [ -n "$BOTO_PROFILE" ]; then
      export AWS_PROFILE="$BOTO_PROFILE"
    fi
    $ANSIBLE_CMD --extra-vars "{_deploy_host: $TARGET_DEPLOY_HOST}" --extra-vars "$ANSIBLE_DEFAULT_EXTRA_VARS" --extra-vars "$ANSIBLE_EXTRA_VARS"
    return $?
  # No host to check provided, just return a clean exit code.
  else
    return 0
  fi
}

# Trigger actual Ansible job.
# $1 (string)
# Operation to perform.
# - deploy
# - revert
# - cleanup
ansible_play(){
  ANSIBLE_BIN=$(command -v ansible-playbook)
  ANSIBLE_CMD="$ANSIBLE_BIN $BUILD_WORKSPACE/$TARGET_DEPLOY_PLAYBOOK"
  if [ "$DRY_RUN" = "yes" ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD --check"
  fi
  if [ "$VERBOSE" = "yes" ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD -vvvv"
  fi
  if [ -n "$BOTO_PROFILE" ]; then
    export AWS_PROFILE="$BOTO_PROFILE"
  fi
  $ANSIBLE_CMD --extra-vars "{deploy_operation: $1}" --extra-vars "$ANSIBLE_DEFAULT_EXTRA_VARS" --extra-vars "$ANSIBLE_EXTRA_VARS"
  return $?
}
# Update repository.
# @param $1 absolute path to local repo.
# @param $2 branch to checkout.
git_checkout(){
  git -C "$1" checkout "$2"
  git -C "$1" pull origin "$2"
}

# Update own repository.
# @param $1 branch to checkout.
git_checkout_own_dir(){
  git_checkout "$OWN_DIR" "$1"
}

# Update own repository.
# @param $1 branch to checkout.
git_checkout_config_dir(){
  git_checkout "$OWN_DIR/config" "$1"
}
