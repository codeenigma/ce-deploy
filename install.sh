#!/bin/sh
set -e

# Load OS information.
# shellcheck source=/dev/null
. /etc/os-release

usage(){
  echo 'install.sh [OPTIONS]'
  echo 'Install the latest ce-deploy version, or the version specified as option.'
  echo 'Please ensure you are using Debian Linux or similar and at least Bullseye (11) or higher.'
  echo ''
  echo 'Available options:'
  echo '--version: ce-deploy version to use (default: 1.x)'
  echo '--user: Ansible deploy user (default: deploy)'
  echo '--ansible-user: User that Ansible is installed as (default: controller)'
  echo '--config: Git URL to your ce-deploy Ansible config repository (default: https://github.com/codeenigma/ce-deploy-config-example.git)'
  echo '--config-branch: branch of your Ansible config repository to use (default: 1.x)'
  echo '--gitlab: install GitLab CE on this server (default: no, set to desired GitLab URL to install)'
  echo '--letsencrypt: try to create an SSL certificate with LetsEncrypt (requires DNS pointing at this server for provided GitLab URL)'
  echo '--aws: enable AWS support'
  echo ''
}

# Parse options arguments.
parse_options(){
  while [ "${1:-}" ]; do
    case "$1" in
      "--version")
          shift
          VERSION="$1"
        ;;
      "--user")
          shift
          DEPLOY_USER="$1"
        ;;
      "--ansible-user")
          shift
          DEPLOY_USER="$1"
        ;;
      "--config")
          shift
          CONFIG_REPO="$1"
        ;;
      "--config-branch")
          shift
          CONFIG_REPO_BRANCH="$1"
        ;;
      "--gitlab")
          shift
          GITLAB_URL="$1"
        ;;
      "--letsencrypt")
          LE_SUPPORT="yes"
        ;;
      "--aws")
          AWS_SUPPORT="true"
        ;;
        *)
        usage
        exit 1
        ;;
    esac
    shift
  done
}

# Set default variables.
VERSION="1.x"
DEPLOY_USER="deploy"
CONTROLLER_USER="controller"
CONFIG_REPO="https://github.com/codeenigma/ce-deploy-config-example.git"
CONFIG_REPO_BRANCH="1.x"
GITLAB_URL="no"
LE_SUPPORT="no"
AWS_SUPPORT="false"
SERVER_HOSTNAME=$(hostname)

# Parse options.
parse_options "$@"

# Set the hostname for Git email to our GitLab URL, if set.
if [ "$GITLAB_URL" != "no" ]; then
  SERVER_HOSTNAME=$GITLAB_URL
fi

# Check root user.
if [ "$(id -u)" -ne 0 ]
  then echo "Please run this script as root or using sudo!"
  exit
fi
 
# Check we are using a compatible Linux distribution.
if [ "$ID" != "debian" ]; then
  if [ "$ID_LIKE" != "debian" ]; then
    echo "ce-deploy only supports Debian Linux and derivatives."
    exit 0
  else
    echo "ce-deploy works best with Debian Linux, it may work with this distro but no promises!"
    echo "-------------------------------------------------"
    echo "Carrying on regardless..."
    echo "-------------------------------------------------"
  fi
fi

echo "Beginning ce-deploy installation."
echo "-------------------------------------------------"

# Create deploy user.
echo "Check if user named $DEPLOY_USER exists."
# Check if user exists.
if id "$DEPLOY_USER" >/dev/null 2>&1; then
  echo "The user named $DEPLOY_USER already exists. Skipping."
else
  # User not found so let's create them.
  echo "Create user named $DEPLOY_USER."
  /usr/sbin/useradd -s /bin/bash "$DEPLOY_USER"
  echo "$DEPLOY_USER":"$DEPLOY_USER" | chpasswd -m
  install -m 755 -o "$DEPLOY_USER" -g "$DEPLOY_USER" -d /home/"$DEPLOY_USER"
  install -m 700 -o "$DEPLOY_USER" -g "$DEPLOY_USER" -d /home/"$DEPLOY_USER"/.ssh
  echo root:"$DEPLOY_USER" | chpasswd -m
fi
echo "-------------------------------------------------"

# Create controller user.
# We still need a controller user because it can sudo and deploy cannot.
echo "Check if user named $CONTROLLER_USER exists."
# Check if user exists.
if id "$CONTROLLER_USER" >/dev/null 2>&1; then
  echo "The user named $CONTROLLER_USER already exists. Skipping."
else
  # User not found so let's create them.
  echo "Create user named $CONTROLLER_USER."
  /usr/sbin/useradd -s /bin/bash "$CONTROLLER_USER"
  echo "$CONTROLLER_USER":"$CONTROLLER_USER" | chpasswd -m
  install -m 755 -o "$CONTROLLER_USER" -g "$CONTROLLER_USER" -d /home/"$CONTROLLER_USER"
  install -m 700 -o "$CONTROLLER_USER" -g "$CONTROLLER_USER" -d /home/"$CONTROLLER_USER"/.ssh
  echo root:"$CONTROLLER_USER" | chpasswd -m
  echo "$CONTROLLER_USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/"$CONTROLLER_USER"
  chmod 0440 /etc/sudoers.d/"$CONTROLLER_USER"
fi
echo "-------------------------------------------------"

# Install APT packages.
echo "Install required packages."
echo "-------------------------------------------------"
/usr/bin/apt-get update
/usr/bin/apt-get dist-upgrade -y -o Dpkg::Options::="--force-confnew"
/usr/bin/apt-get install -y -o Dpkg::Options::="--force-confnew" \
  git ca-certificates git-lfs \
  openssh-client nfs-common stunnel4 \
  python3-venv python3-debian \
  zip unzip gzip tar dnsutils
echo "-------------------------------------------------"

# Install Ansible in a Python virtual environment.
echo "Install Ansible and dependencies."
echo "-------------------------------------------------"
su - "$DEPLOY_USER" -c "/usr/bin/python3 -m venv /home/$DEPLOY_USER/ce-python"
su - "$DEPLOY_USER" -c "/home/$DEPLOY_USER/ce-python/bin/python3 -m pip install --upgrade pip"
su - "$DEPLOY_USER" -c "/home/$DEPLOY_USER/ce-python/bin/pip3 install ansible netaddr"
su - "$DEPLOY_USER" -c "/home/$DEPLOY_USER/ce-python/bin/ansible-galaxy collection install ansible.posix --force" 
if [ "$AWS_SUPPORT" = "true" ]; then
  su - "$DEPLOY_USER" -c "/home/$DEPLOY_USER/ce-python/bin/pip3 install boto3"
fi
echo "-------------------------------------------------"

# @TODO need to temporarily install ce-provision to install ce-deploy

# Install ce-deploy.
echo "Install ce-deploy."
echo "-------------------------------------------------"
if [ ! -d "/home/$DEPLOY_USER/ce-deploy" ]; then
  su - "$DEPLOY_USER" -c "git clone --branch $VERSION https://github.com/codeenigma/ce-deploy.git /home/$DEPLOY_USER/ce-deploy"
else
  echo "ce-deploy directory at /home/$DEPLOY_USER/ce-deploy already exists. Skipping."
  echo "-------------------------------------------------"
fi
# Create playbook.
/usr/bin/cat >"/home/$DEPLOY_USER/ce-deploy/provision.yml" << EOL
---
- hosts: "localhost"
  become: true
  vars_files:
    - vars.yml
  tasks:
    - name: Install ce-deploy.
      ansible.builtin.import_role:
        name: debian/ce_deploy
    - name: Install iptables firewall.
      ansible.builtin.import_role:
        name: debian/firewall_config
EOL
# Create vars file.
/usr/bin/cat >"/home/$DEPLOY_USER/ce-provision/vars.yml" << EOL
_domain_name: ${SERVER_HOSTNAME}
_ce_provision_data_dir: /home/${DEPLOY_USER}/ce-provision/data
_ce_provision_username: ${DEPLOY_USER}
ce_provision:
  venv_path: /home/${DEPLOY_USER}/ansible
  venv_command: /usr/bin/python3 -m venv
  venv_install_username: ${DEPLOY_USER}
  upgrade_timer_name: upgrade_ce_provision_ansible
  aws_support: ${AWS_SUPPORT}
  new_user: ${DEPLOY_USER}
  username: ${DEPLOY_USER}
  public_key_name: id_rsa.pub
  own_repository: "https://github.com/codeenigma/ce-deploy.git"
  own_repository_branch: "${VERSION}"
  own_repository_skip_checkout: false
  local_dir: "/home/${DEPLOY_USER}/ce-deploy"
  config_repository: "${CONFIG_REPO}"
  config_repository_branch: "${CONFIG_REPO_BRANCH}"
  config_repository_skip_checkout: false
  groups: []
  contrib_roles:
    - directory: wazuh
      repo: https://github.com/wazuh/wazuh-ansible.git
      branch: "v4.7.2"
    - directory: systemd_timers
      repo: https://github.com/vlcty/ansible-systemd-timers.git
      branch: master
  galaxy_custom_requirements_file: ""
  upgrade_galaxy:
    enabled: true
    command: "/home/${DEPLOY_USER}/ansible/bin/ansible-galaxy collection install --force"
    on_calendar: "Mon *-*-* 04:00:00"
firewall_config:
  purge: true
  firewall_state: started
  firewall_enabled_at_boot: true
  firewall_enable_ipv6: false
  firewall_log_dropped_packets: true
  firewall_disable_ufw: true
  firewall_allowed_tcp_ports: []
  rulesets:
    - ssh_open
    - web_open
  ssh_open:
    firewall_allowed_tcp_ports:
      - "22"
  web_open:
    firewall_allowed_tcp_ports:
      - "80"
      - "443"
EOL
su - "$DEPLOY_USER" -c "/home/$DEPLOY_USER/ce-python/bin/ansible-playbook /home/$DEPLOY_USER/ce-deploy/provision.yml"
echo "-------------------------------------------------"

# Install GitLab
if [ "$GITLAB_URL" != "no" ]; then
  echo "Install GitLab."
  echo "-------------------------------------------------"
  # Create playbook.
  /usr/bin/cat >"/home/$DEPLOY_USER/ce-deploy/provision.yml" << EOL
---
- hosts: "localhost"
  become: true
  vars_files:
    - vars.yml
  tasks:
    - name: Install GitLab Runner.
      ansible.builtin.import_role:
        name: debian/gitlab_runner
    - name: Install GitLab.
      ansible.builtin.import_role:
        name: debian/gitlab
EOL
  # Create vars file.
  /usr/bin/cat >"/home/$DEPLOY_USER/ce-deploy/vars.yml" << EOL
gitlab_runner:
  apt_origin: "origin=packages.gitlab.com/runner/gitlab-runner,codename=\${distro_codename},label=gitlab-runner" # used by apt_unattended_upgrades
  apt_signed_by: https://packages.gitlab.com/runner/gitlab-runner/gpgkey
  concurrent_jobs: 10
  check_interval: 0
  session_timeout: 1800
  runners: []
  install_fargate: false
  restart: false
  username: "${DEPLOY_USER}"
  docker_group: "docker"
  runner_workingdir: "/home/${DEPLOY_USER}/build"
  runner_config: "/etc/gitlab-runner/config.toml"
gitlab:
  apt_origin: "origin=packages.gitlab.com/gitlab/gitlab-ce,codename=\${distro_codename},label=gitlab-ce" # used by apt_unattended_upgrades
  apt_signed_by: https://packages.gitlab.com/gitlab/gitlab-ce/gpgkey
  server_name: "${GITLAB_URL}"
  email: "gitlab@${GITLAB_URL}"
  gitlab_route_53:
    zone: ""
  linux_user: git
  linux_group: git
  linux_uid: nil
  linux_gid: nil
  linux_shell: /bin/sh
  linux_user_home: /var/opt/gitlab
  username: GitLab
  email: "gitlab@${GITLAB_URL}"
  default_theme: 1
  disable_signup: true
  disable_signin: false
  private_projects: true
  unicorn_worker_processes: 2
  puma_worker_processes: 2
  initial_root_password: "Ch@ng3m3"
  ldap:
    enable: false
  mattermost: false
  omniauth: false
  prometheus: "true"
  node_exporter: "true"
  alertmanager: "true"
  nginx:
    enable: true
    listen_port: 443
    listen_https: 443
    client_max_body_size: "250m"
    redirect_http_to_https: "true"
    redirect_http_to_https_port: 80
    custom_nginx_config: ""
EOL
  if [ "$LE_SUPPORT" = "yes" ]; then
    echo "Will try to create an SSL certificate with LetsEncrypt."
    echo "*** THIS STEP WILL FAIL IF YOUR DNS IS NOT CORRECT! ***"
    if [ -n "$(dig +short "$GITLAB_URL".)" ]; then
      echo "DNS record found, attempting LetsEncrypt request..."
      # Write GitLab vars with LE for SSL
      cat <<EOT >> "/home/$DEPLOY_USER/ce-deploy/vars.yml"
  letsencrypt: "true"
  ssl:
    enabled: false
EOT
      echo "-------------------------------------------------"
    else
      echo "No DNS found for provided URL, will create a self-signed certificate instead."
      # Write GitLab vars with self-signed SSL
      cat <<EOT >> "/home/$DEPLOY_USER/ce-deploy/vars.yml"
  letsencrypt: "false"
  ssl:
    enabled: true
    handling: selfsigned
    replace_existing: false
EOT
      echo "-------------------------------------------------"
    fi
  else
    # Write GitLab vars with self-signed SSL
    echo "Create a self-signed SSL certificate."
    cat <<EOT >> "/home/$DEPLOY_USER/ce-deploy/vars.yml"
  letsencrypt: "false"
  ssl:
    enabled: true
    handling: selfsigned
    replace_existing: false
EOT
    echo "-------------------------------------------------"
  fi
  su - "$DEPLOY_USER" -c "/home/$DEPLOY_USER/ce-python/bin/ansible-playbook /home/$DEPLOY_USER/ce-deploy/provision.yml"
  echo "-------------------------------------------------"
else
  echo "GitLab not requested. Skipping."
  echo "-------------------------------------------------"
fi
rm "/home/$DEPLOY_USER/ce-deploy/vars.yml"
rm "/home/$DEPLOY_USER/ce-deploy/provision.yml"
echo "DONE."
