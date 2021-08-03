# Helper stack for working locally on Ansible roles.

This will spin up some Docker containers to be able to run roles against.
By default, it will create:

- a "controller" container, which acts as the deploy server. This "ce-deploy" repo is mounted at /home/ce-dev/ce-deploy, so all changes (to roles, etc) made from your host computer are directly available within the container
- a target web server, called **deploy-web**, which has standard privileges.
- a database server, called **deploy-db**, which is the default MariaDB image from Docker Hub.

## Pre-requesites

You'll need https://github.com/codeenigma/ce-dev installed.

You'll need to set up a `config` directory in the root of the cloned `ce-deploy` project, the deploy playbooks expect it to exist and to have `ansible.cfg` within. If you already have a private config repo for your organisation that should be cloned here. If you do not, you can use our provided example repo to get started with - https://github.com/codeenigma/ce-deploy-config-example

## Usage

### 1. Generate the actual docker-compose file and start the containers

`ce-dev init && ce-dev start`

### 2. Provision the controller server

`ce-dev provision`

This needs to be done first, so the deploy user can be correctly populated and the controller server is setup.

### 3. Amend the git remote(s)

The setup step uses the standard repo path, https://github.com/codeenigma/ce-deploy.git which is not suitable for pushing/MR.
You need to manually amend it to use the ssh version (or point it to your private fork).

```
git remote remove origin
git remote add origin git@github.com:codeenigma/ce-deploy.git
```

### 4. Create your playbook(s)

You can start creating playbooks in the ce-dev/ansible/local directory which is .gitignored (copy them from the examples folder).

When testing locally you can include the 'common.yml' vars file, as it will set all the needed variables to be able to work locally and call ansible-playbook directly without going through the wrapper script (see below).

### 5. Ensure your hosts are properly configured

If you run step 6 without hosts configured you will get a `skipping: no hosts matched` message and nothing will happen. There needs to be a `hosts` or `hosts.yml` file in your config directory, which is fetched during the Pre-requesites step above, for example:

* https://github.com/codeenigma/ce-deploy-config-example/blob/master/hosts/hosts.yml

You need to ensure this exists and the correct IP addresses are defined (you can check this with `ping` or by looking at the `/etc/hosts` file on the host machine). Note, other formats are also valid. See the docs for details:

* https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html

### 6. Run, amend/create your roles, rince and repeat

`ce-dev shell`

Select the `deploy-controller` instance to connect to. From there, you can run a playbook to deploy to the deploy-web server. There are two ways to run playbooks.

1.  From the **~/ce-deploy** directory, run:
    `ansible-playbook ce-dev/ansible/local/my-playbook.yml`

2.  Use the `build.sh` wrapper script. As you're working locally, you can use the `--workspace` argument:
    `/bin/sh /home/ce-dev/ce-deploy/scripts/build.sh --workspace /home/ce-dev/ce-deploy --playbook ce-dev/ansible/local/my-playbook.yml --build-number 0 --build-id example`
