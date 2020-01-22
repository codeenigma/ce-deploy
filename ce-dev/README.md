# Helper stack for working locally on Ansible roles.

This will spin up some Docker containers to be able to run roles against.
By default, it will create:
- a "controller" container, which acts as the provisioning server. This "ansible-provision" repo is mounted at /home/ce-dev/ansible-provision, so all changes (to roles, etc) made from your host computer are directly available within the container
- an exemple "utility" server that can be targeted for provisioning
- an exemple "web" server that can be targeted for provisioning

You can add more or amend those by defining them in the ce-dev.compose.yml file.

Each of the "targets" has a matching playbook in the ce-dev/ansible folder.

## Pre-requesites
You'll need https://github.com/codeenigma/ce-dev installed.

## Usage

Once you've reviewed the playbooks and uncommented the roles you needed (most are commented by default to speed up the process), you can spin up the project.

### 1. Generate the actual docker-compose file and start the containers
```ce-dev init && ce-dev start```

### 2. Provision the utility server
```ce-dev provision```
And select the "provision-utility" server. It needs to be done before any other target, so the deploy user can be correctly populated.

### 3. Provision the web target (or any other target you created)
```ce-dev provision```
And select the container you want to target.

### 3. Amend/create your roles, rince and repeat