#!/bin/sh

set -eu

usage(){
  echo 'track-set.sh --repo <git repo to deploy> --branch <branch to deploy> --playbook <path to playbook> --previous-stable-build-number < incremental build number>'
  echo 'Stores last known good build number for a given build.'
  echo ''
  echo 'Mandatory arguments:'
  echo '--repo: Path to a remote git repo. The "deploy" user must have read access to it.'
  echo '--branch: The branch to deploy.'
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
if [ -z "$TARGET_DEPLOY_REPO" ] || [ -z "$TARGET_DEPLOY_PLAYBOOK" ] || [ -z "$TARGET_DEPLOY_BRANCH" ] || [ -z "$PREVIOUS_BUILD_NUMBER" ]; then
 usage
 exit 1
fi

# Construct track path.
set_build_track_file

# Update build number.
set_previous_build_number "$PREVIOUS_BUILD_NUMBER"

echo "$PREVIOUS_BUILD_NUMBER"