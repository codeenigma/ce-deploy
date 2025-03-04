# ASG Management
This role should be called in a separate playbook to the rest of the build with the host set as `localhost`, not the target ASG group. The available hosts in the ASG group may change after it has run, so Ansible needs to interogate the ASG host group after this play has run and before building.

In order to manipulate an AWS Autoscaling Group (ASG) your `deploy` user must have an AWS CLI profile for a user with the following IAM permissions:
* `autoscaling:ResumeProcesses`
* `autoscaling:SuspendProcesses`
* `autoscaling:DescribeScalingProcessTypes`
* `autoscaling:DescribeAutoScalingGroups`

Set the `asg_management.name` to the machine name of your ASG in order to automatically suspend and resume autoscaling on build.

## Recommended playbook setup
To use this role the recommended approach is three different playbooks. Don't forget to add the `asg_management` variables to your variables file as well, see the defaults below for guidance.

### `deploy-dev.yml`

```yaml
---
- name: Stop ASG processes.
  ansible.builtin.import_playbook: asg-dev.yml
  vars:
    install_php_cachetool: false

- name: Build website.
  ansible.builtin.import_playbook: build-dev.yml

- name: Start ASG processes.
  ansible.builtin.import_playbook: asg-dev.yml
  vars:
    install_php_cachetool: false
```

### `asg-dev.yml`

```yaml
---
- hosts: localhost
  vars_files:
    - vars/common.yml
    - vars/dev.yml
  roles:
    - _init
    - asg_management
    - _exit
```

### `build-dev.yml`

```yaml
---
- hosts: _dev_acme_com
  vars_files:
    - vars/common.yml
    - vars/dev.yml
  roles:
    - _meta/deploy-drupal8
```

### Process explained
Your CI will call `deploy-dev.yml`. This will run the ASG playbook, the `_init` role will set the ce-deploy lock file on localhost - the CI server itself - the `asg_management` role will check for that lock file and, if it exists, will suspend ASG processes. The `_exit` role will be executed, but will *not* remove the lock file because we are on the `deploy` operation.

Then the build playbook is called and runs as normal on the ASG machines.

Finally, the ASG playbook runs again. It will re-suspend the ASG for the same logical reason, which loses us a few seconds, but doesn't to any harm. Once again, we are still in the `deploy` operation so the lock file will not get deleted by `_exit`

The bash script will then take us to either the `cleanup` or `revert` operation, depending on whether or not Ansible exited with an error code on the `deploy` operation. Either way, the ASG play will run and ASG processes will stay suspended, because the lock file is still there. At the end of the play the `_exit` role will delete the lock file on localhost (lock files on ASG servers still exist at this point). The build playbook will execute and run either cleanup or revert, depending on the operation, then the ASG playbook will run a final time. At this point the `asg_management` role will detect the lock file on localhost is no longer present and enable the ASG processes again.

<!--TOC-->
<!--ENDTOC-->

<!--ROLEVARS-->
<!--ENDROLEVARS-->
