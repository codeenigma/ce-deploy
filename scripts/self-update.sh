#!/bin/sh

set -eu

usage(){
  echo 'self-update.sh [OPTIONS] --own-branch <branch-to-use-for-stack> --config-branch <branch-to-use-for-config>'
  echo 'Update (git pull) the stack.'
  echo ''
  echo 'Mandatory arguments:'
  echo '--own-branch: Branch to use for the main stack repository'
  echo '--config-branch: Branch to use for the main stack config repository'
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

exit 0