#!/bin/sh

set -eu

usage(){
  echo 'ansible-deploy.sh [OPTIONS] --repo <git repo to deploy> --branch <branch to deploy> --playbook <path to playbook> --buildnumber < incremental build number>'
  echo 'Deploy an application.'
  echo ''
  echo 'Mandatory arguments:'
  echo '--repo: Path to a remote git repo. The "deploy" user must have read access to it.'
  echo '--branch: The branch to deploy.'
  echo '--playbook: Relative path to an ansible playbook within the repo.'
  echo '--buildnumber: an incremental build number'
  echo ''
  echo 'Available options:'
  echo '--ansible-extra-vars: Variable to pass as --extra-vars arguments to ansible-playbook. Make sure to escape them properly.'
}

# Remove temp dir on exit.
cleanup_exit(){
  set +e
  if [ "$ANSIBLE_BUILD_RESULT" != 0 ]; then
    /usr/bin/ansible-playbook --verbose "$TARGET_PLAYBOOK_PATH"  --extra-vars '{deploy_operation: revert}' --extra-vars "$ANSIBLE_DEFAULT_EXTRA_VARS" --extra-vars "$ANSIBLE_EXTRA_VARS"
  fi
  if [ -n "$BUILD_DIR" ] && [ -d "$BUILD_DIR" ]; then
    rm -rf "$BUILD_DIR"
  fi
  exit "$ANSIBLE_BUILD_RESULT"
}

# Parse long options.
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
      "--buildnumber")
          shift
          BUILD_NUMBER="$1"
        ;;
      "--ansible-extra-vars")
          shift
          ANSIBLE_EXTRA_VARS="$1"
        ;;
        *)
        usage
        exit 1
        ;;
    esac
    shift
  done
}

# Clone our target repo.
repo_target_clone(){
  git clone "$TARGET_DEPLOY_REPO" "$BUILD_DIR" --depth 1 --branch "$TARGET_DEPLOY_BRANCH"
}

# Default vars.
TARGET_DEPLOY_REPO=""
TARGET_DEPLOY_PLAYBOOK=""
TARGET_DEPLOY_BRANCH=""
BUILD_NUMBER=""
PREVIOUS_BUILD_NUMBER=0
ANSIBLE_EXTRA_VARS=""
ANSIBLE_BUILD_RESULT=0
# Compute actual location.
OWN_DIR=$(dirname "$0")
cd "$OWN_DIR" || exit 1
OWN_DIR=$(pwd -P)
export ANSIBLE_CONFIG="$OWN_DIR/ansible.cfg"

# Make sure we exit cleanly.
trap cleanup_exit EXIT INT TERM QUIT HUP

# Base settings. We can't use mktemp directly, Ansible gets confused when run from /tmp.
BUILD_DIR_BASE="$OWN_DIR/build"
if [ ! -d "$BUILD_DIR_BASE" ]; then
  mkdir "$BUILD_DIR_BASE"
fi
BUILD_DIR_TRACK="$BUILD_DIR_BASE/track"
if [ ! -d "$BUILD_DIR_TRACK" ]; then
  mkdir "$BUILD_DIR_TRACK"
fi
BUILD_DIR=$(mktemp -d -p "$BUILD_DIR_BASE")

# Parse options and make sure everything's up to date.
parse_options "$@"

# Check we have enough arguments.
if [ -z "$TARGET_DEPLOY_REPO" ] || [ -z "$TARGET_DEPLOY_PLAYBOOK" ] || [ -z "$TARGET_DEPLOY_BRANCH" ] || [ -z "$BUILD_NUMBER" ]; then
 usage
 exit 1
fi

# Check if we know about previous builds.
BUILD_FILE_TRACK="$BUILD_DIR_TRACK/$(echo "$TARGET_DEPLOY_REPO-$TARGET_DEPLOY_BRANCH-$TARGET_DEPLOY_PLAYBOOK" | tr / -)"
if [ -f "$BUILD_FILE_TRACK" ]; then
  PREVIOUS_BUILD_NUMBER=$(cat "$BUILD_FILE_TRACK")
fi

TARGET_PLAYBOOK_PATH="$BUILD_DIR/$TARGET_DEPLOY_PLAYBOOK"
ANSIBLE_DEFAULT_EXTRA_VARS="{local_build_path: $BUILD_DIR, build_number: $BUILD_NUMBER, target_playbook: $TARGET_PLAYBOOK_PATH, previous_known_build_number: $PREVIOUS_BUILD_NUMBER}"

# Clone target repo.
repo_target_clone
# Trigger actual provisioning. From this point on, we revert in case of failure.
ANSIBLE_BUILD_RESULT=1
/usr/bin/ansible-playbook --verbose "$TARGET_PLAYBOOK_PATH"  --extra-vars "{deploy_operation: deploy}" --extra-vars "$ANSIBLE_DEFAULT_EXTRA_VARS" --extra-vars "$ANSIBLE_EXTRA_VARS"
ANSIBLE_BUILD_RESULT=$?
# Keep track of successful build.
# This means we loose track of it when changing repo,
# but avoids coming with an additional parameter.
# The Ansible side will correct this using the live symlink,
# so should not be an issue anyway.
if [ -n "$ANSIBLE_BUILD_RESULT" ] && [ "$ANSIBLE_BUILD_RESULT" = 0 ]; then
  echo "$BUILD_NUMBER" > "$BUILD_FILE_TRACK"
  # Clean up the builds. Note that we won't revert if that fail, as the "build" itself is successful.
  # We still exit with an error, so it gets flagged.
  /usr/bin/ansible-playbook --verbose "$TARGET_PLAYBOOK_PATH"  --extra-vars "{deploy_operation: cleanup}" --extra-vars "$ANSIBLE_DEFAULT_EXTRA_VARS" --extra-vars "$ANSIBLE_EXTRA_VARS"
  exit 0
fi
# Failed.
exit 1
