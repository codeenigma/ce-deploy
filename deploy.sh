#!/bin/sh

set -eu

# Compute actual location.
OWN_DIR=$(dirname "$0")
cd "$OWN_DIR" || exit 1
OWN_DIR=$(pwd -P)

# shellcheck source=./common.sh
. "$OWN_DIR/common.sh"

# Trigger own updates.
/usr/bin/ansible-playbook "$OWN_DIR/playbooks/self-update.yml" --extra-vars "$ANSIBLE_DEFAULT_EXTRA_VARS" --extra-vars "$ANSIBLE_EXTRA_VARS"

# Trigger actual provisioning.
set +e
/usr/bin/ansible-playbook "$TARGET_PLAYBOOK_PATH" --extra-vars "$ANSIBLE_DEFAULT_EXTRA_VARS" --extra-vars "$ANSIBLE_EXTRA_VARS"
ANSIBLE_BUILD_RESULT=$?
set -e
# Keep track of successful build.
# This means we loose track of it when changing repo,
# but avoids coming with an additional parameter.
# The Ansible side will correct this using the live symlink,
# so should not be an issue anyway.
if [ -n "$ANSIBLE_BUILD_RESULT" ] && [ "$ANSIBLE_BUILD_RESULT" = 0 ]; then
  echo "$BUILD_NUMBER" > "$BUILD_FILE_TRACK"
  exit 0
fi
# Failed.
exit 1
