#!/bin/sh

set -eu

usage(){
  echo 'ansible-deploy.sh [OPTIONS] --repo <git repo to deploy> --playbook <path to playbook> --branch <branch to deploy> --buildtype <build identifier> --buildnumber < incremental build number>'
  echo 'Deploy an application.'
  echo ''
  echo 'Mandatory arguments:'
  echo '--repo: Path to a remote git repo. The "deploy" user must have read access to it.'
  echo '--playbook: Relative path to an ansible playbook within the repo.'
  echo '--branch: The branch to deploy.'
  echo '--buildtype: An identifier for the build type, eg "prod", "dev", "mycustombuild", ...'
  echo '--buildnumber: an incremental build number'
  echo ''
  echo 'Available options:'
  echo '--ansible-extra-vars: Variable to pass as --extra-vars arguments to ansible-playbook. Make sure to escape them properly.'
  echo '--deploy-user: Name of the "deploy" user on that system. Defaults to "deploy"'
  echo '--no-prompt: skip confirmation dialogs.'
  echo '--own-branch: the git branch to use for the deployment scripts repository. Default to "master".'
  echo '--skip-own-update: skip checking the deployment scripts are up to date and checking out to a branch.'
}

# Remove temp dir on exit.
cleanup_exit(){
  if [ -n "$BUILD_DIR" ] && [ -d "$BUILD_DIR" ]; then
    rm -rf "$BUILD_DIR"
  fi
}

# Confirmation dialog.
# @param string
# Message to display.
confirm(){
  echo "$1 (y/n)?" 
  read -r _confirm
  case "$_confirm" in 
    'y'|'Y'|'yes'|'Yes')
      return
    ;;
    * )
      echo "Operation cancelled"
      return 1
    ;;
  esac
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
      "--buildtype")
          shift
          BUILD_TYPE="$1"
        ;;
      "--buildnumber")
          shift
          BUILD_NUMBER="$1"
        ;;
      "--deploy-user")
          shift
          ANSIBLE_DEPLOY_USER="$1"
        ;;
      "--ansible-extra-vars")
          shift
          ANSIBLE_EXTRA_VARS="$1"
        ;;
      "--no-prompt")
          NON_INTERACTIVE_MODE="yes"
        ;;
      "--skip-own-update")
          SKIP_OWN_UPDATE="yes"
        ;;
      "--own-branch")
          shift
          ANSIBLE_DEPLOY_BRANCH="$1"
        ;;
        *)
        usage
        exit 1
        ;;
    esac
    shift
  done
}

# Update a repo.
# @param $1 string
# Local repo filepath.
# @param $2 branch
# Branch name to checkout.
repo_update(){
  git -C "$1" fetch
  git -C "$1" checkout "$2"
  git -C "$1" pull origin "$2"  
}

# Ensure a local clone of a repo.
# @param $1 string
# Remote repository.
# @param $2 string
# Local clone destination.
repo_clone(){
  if [ ! -d "$2" ]; then
    git clone "$1" "$2"
  fi 
}

# Update the Ansible wrapper repo itself.
repo_own_update(){
  repo_update "$OWN_DIR" "$ANSIBLE_DEPLOY_BRANCH"
  sudo rsync -avz --delete --exclude="roles" --chown="$CURRENT_CALLER:$CURRENT_CALLER" "$OWN_DIR/etc/" "/etc/ansible"
}

# Ensure the Ansible roles are up-to-date.
repo_roles_update(){
  repo_clone "$ANSIBLE_DEPLOY_ROLES_REMOTE" "$ANSIBLE_DEPLOY_ROLES_LOCAL"
  repo_update "$ANSIBLE_DEPLOY_ROLES_LOCAL" "$ANSIBLE_DEPLOY_BRANCH"
}

# Clone our target repo.
repo_target_clone(){
  git clone "$TARGET_DEPLOY_REPO" "$BUILD_DIR" --depth 1 --branch "$TARGET_DEPLOY_BRANCH"
}

# Target deployment.
# @param $1 string
# Operation to perform (either deploy or revert)
ansible_deploy(){
  if [ ! "$NON_INTERACTIVE_MODE" = "yes" ]; then
    confirm "Deploy $TARGET_DEPLOY_REPO ?"
    if [ "$?" = "1" ]; then
      exit 0
    fi
  fi
  _ansible_deploy "$1"
}

# Actual deployment.
# @param $1 string
# Operation to perform (either deploy or revert)
_ansible_deploy(){
  TARGET_PLAYBOOK_PATH="$BUILD_DIR/$TARGET_DEPLOY_PLAYBOOK"
  ANSIBLE_DEFAULT_EXTRA_VARS="{local_build_path: $BUILD_DIR, build_type: $BUILD_TYPE, build_number: $BUILD_NUMBER, target_playbook: $TARGET_PLAYBOOK_PATH, previous_known_build_number: $PREVIOUS_BUILD_NUMBER, deploy_user: $ANSIBLE_DEPLOY_USER}"
  echo /usr/bin/ansible-playbook "$TARGET_PLAYBOOK_PATH" --extra-vars "$ANSIBLE_DEFAULT_EXTRA_VARS" --extra-vars "$ANSIBLE_EXTRA_VARS"
  return $?
}

# Compute actual location.
OWN_DIR=$(dirname "$0")
cd "$OWN_DIR" || exit 1
OWN_DIR=$(pwd -P)

# Make sure we exit cleanly.
trap cleanup_exit EXIT INT TERM QUIT HUP

# Base settings. We can't use mktemp, Ansible WTF cannot "find" certain files.
BUILD_DIR_BASE="$OWN_DIR/build"
if [ ! -d "$BUILD_DIR_BASE" ]; then
  mkdir "$BUILD_DIR_BASE"
fi
BUILD_DIR_TRACK="$BUILD_DIR_BASE/track"
if [ ! -d "$BUILD_DIR_TRACK" ]; then
  mkdir "$BUILD_DIR_TRACK"
fi
BUILD_DIR=$(mktemp -d -p "$BUILD_DIR_BASE")

# Provisioning scripts location.
ANSIBLE_DEPLOY_BRANCH="master"
ANSIBLE_DEPLOY_ROLES_REMOTE="git@jenkins.codeenigma.com:ce-ops/the-master-plan/ansible-deploy-roles.git"
ANSIBLE_DEPLOY_ROLES_LOCAL="/etc/ansible/roles"
# Default deploy user.
ANSIBLE_DEPLOY_USER='deploy'
# Target app.
TARGET_DEPLOY_REPO=""
TARGET_DEPLOY_BRANCH=""
TARGET_DEPLOY_PLAYBOOK=""
# Build info.
BUILD_TYPE=""
BUILD_NUMBER=""
PREVIOUS_BUILD_NUMBER=0
# Interactive mode.
NON_INTERACTIVE_MODE="no"
# Skip pulling git latest version.
SKIP_OWN_UPDATE="no"
# Optional extras vars.
ANSIBLE_EXTRA_VARS=""
# Parse options and make sure everything's up to date.
parse_options "$@"


# Check we're running as the right user.
CURRENT_CALLER=$(whoami)
if [ "$CURRENT_CALLER" != "$ANSIBLE_DEPLOY_USER" ] && [ "$CURRENT_CALLER" != "ce-dev" ]; then
  echo "This script needs to be run as the deploy user"
  exit 1
fi
# Local use, we don't update repos as they're local.
if [ "$CURRENT_CALLER" = "ce-dev" ]; then
  SKIP_OWN_UPDATE="yes"
  ANSIBLE_DEPLOY_USER='ce-dev'
fi

# Check we have enough arguments.
if [ -z "$TARGET_DEPLOY_REPO" ] || [ -z "$TARGET_DEPLOY_PLAYBOOK" ] || [ -z "$TARGET_DEPLOY_BRANCH" ] || [ -z "$BUILD_TYPE" ] || [ -z "$BUILD_NUMBER" ]; then
 usage
 exit 1
fi

# Update the various repos.
if [ "$SKIP_OWN_UPDATE" = "no" ]; then
  repo_own_update
  repo_roles_update
fi
# Check if we know about previous builds.
BUILD_FILE_TRACK="$BUILD_DIR_TRACK/$(echo $TARGET_DEPLOY_REPO-$BUILD_TYPE | tr / -)"
if [ -f "$BUILD_FILE_TRACK" ]; then
  PREVIOUS_BUILD_NUMBER=$(cat "$BUILD_FILE_TRACK")
fi
# Trigger actual provisioning.
repo_target_clone
set +e
ansible_deploy "deploy"
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
# Revert build.
ansible_deploy "revert"
exit 1