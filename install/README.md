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
### Configuration
