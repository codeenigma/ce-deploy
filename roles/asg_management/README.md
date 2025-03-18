# ASG Management
This role should be called in a separate playbook, e.g. a separate command in CI, to the rest of the build with the host set as `localhost` and not the target ASG group. The available hosts in the ASG group may change after it has run, so Ansible needs to interogate the ASG host group after this play has run and before building. This cannot be done unless Ansible stops and starts again.

In order to manipulate an AWS Autoscaling Group (ASG) your `deploy` user must have an AWS CLI profile for a user with the following IAM permissions:
* `autoscaling:ResumeProcesses`
* `autoscaling:SuspendProcesses`
* `autoscaling:DescribeScalingProcessTypes`
* `autoscaling:DescribeAutoScalingGroups`

Set the `asg_management.name` to the machine name of your ASG in order to automatically suspend and resume autoscaling on build.

## Recommended playbook setup
To use this role the recommended approach is two different playbooks and separate Ansible commands. Don't forget to add the `asg_management` variables to your variables file as well. Below you will find a GitLab CI example and suggested variables.

### `.gitlab-ci.yml`

```yaml
---
stages:
  - deploy

deploy_dev:
  stage: deploy
  script:
    - /bin/sh /home/deploy/ce-deploy/scripts/deploy.sh --workspace "$CI_PROJECT_DIR" --playbook deploy/asg.yml --ansible-extra-vars "{\"build_type\":\"$BUILD_TYPE\",\"install_php_cachetool\":false}" --build-number ${CI_PIPELINE_IID} --build-id acme-dev --boto-profile acme
    - /bin/sh /home/deploy/ce-deploy/scripts/build.sh --workspace "$CI_PROJECT_DIR" --playbook deploy/deploy-dev.yml --build-number ${CI_PIPELINE_IID} --build-id acme-dev --boto-profile acme
    - /bin/sh /home/deploy/ce-deploy/scripts/cleanup.sh --workspace "$CI_PROJECT_DIR" --playbook deploy/asg.yml --ansible-extra-vars "{\"build_type\":\"$BUILD_TYPE\",\"install_php_cachetool\":false}" --build-number ${CI_PIPELINE_IID} --build-id acme-dev --boto-profile acme
  rules:
    - if: '$CI_PIPELINE_SOURCE != "web" && $CI_COMMIT_BRANCH == "dev"'
    - if: '$CI_PIPELINE_SOURCE == "web" && $SYNC == "no" && $BUILD_TYPE == "dev"'
```

### `asg.yml`

```yaml
---
- hosts: localhost
  vars_files:
    - vars/common.yml
    - "vars/{{ build_type }}.yml"
  roles:
    - asg_management
```

### `deploy-dev.yml`

```yaml
---
- hosts: _ce_www_acme_codeenigma_net # ASG group name from EC2 discovery
  vars_files:
    - vars/common.yml
    - vars/dev.yml
  roles:
    - _meta/deploy-drupal8
```

### Process explained
The example is a single development environment Drupal build. Your CI will call `asg.yml` with the `deploy.sh` script which will *only* run the `deploy` operation, therefore it will try to suspend ASG processes and wait until the ASG has settled down before continuing. After that we call a normal Drupal build, `deploy-dev.yml`, same as you would if it were a standalone server or a static cluster. Finally, we call `asg.yml` again but this time with the `cleanup.sh` script which will *only* run the `cleanup` operation, therefore it will re-enable the suspended ASG processes.

<!--TOC-->
<!--ENDTOC-->

<!--ROLEVARS-->
<!--ENDROLEVARS-->
