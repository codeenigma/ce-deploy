# Drupal 10
Role for deploying single Drupal instances, or multisites with a single database, of Drupal version 10.0.0 or higher.

You should always top and tail this role with the `_init` and `_exit` roles and include the files with your Ansible variable overrides in via `vars_files`, here is an example playbook:

```yaml
---
- hosts: web1.example.com
  vars_files:
    - vars/common.yml
    - vars/prod.yml
  roles:
    - _init
    - _meta/deploy-drupal10
    - _exit
```

<!--ROLEVARS-->
<!--ENDROLEVARS-->
