#!/bin/sh

set -eu

usage(){
  echo 'track-get.sh --build-id <custom identifier>'
  echo 'Returns last known good build number for a given build.'
  echo ''
  echo 'Mandatory arguments:'
  echo '--build-id: A custom identifier used to "track" successful deployments.'
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
if [ -z "$BUILD_ID" ]; then
 usage
 exit 1
fi

# Construct track path.
get_build_track_file

# Check if we know about previous builds.
get_previous_build_number

echo "$PREVIOUS_BUILD_NUMBER"