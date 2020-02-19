# Install
The stack only gets tested on Debian Buster, but should run on any Linux distribution, as long as Ansible >=2.9 is present.

## Using ansible-provision
The companion [ansible-provision](https://github.com/codeenigma/ansible-provision) stack already provides an "ansible_deploy" role you can add to your playbooks.

## Docker
@todo Docker image to come soon.

## Manual install

### Dependencies
The main prerequesites are obviously Ansible and git. Depending on how you setup your inventory, you might need some other Python libraries (eg Boto3 for AWS).
You will also need a local user to install locally, by convention we'll name it "deploy", but you can easily override that.
### Installation
1. Clone this repository (typically to the deploy user `$HOME` directory)
2. Copy the install/example.vars.yml file to install/vars.yml
3. Amend the vars.yml file, and change the ansible_deploy.username to your "deploy" user.
4. Run the install playbook: ```ansible-playbook install/self-update.yml --extra-vars="@install/vars.yml" ```
Past this step, the vars.yml file can be safely deleted.

## Configuration
Past the initial setup, you will want to manage your configuration (hosts, etc) independantly.
To do so, amend the default that have been cloned in the "config" subdirectory, and
- point the git remote to the new location in which you want to manage your configuration
- make sure the ansible_deploy.config_repository variable defaults to the same repository.
