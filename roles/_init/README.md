# Init
Mandatory role that must run before any other `ce-deploy` roles when executing a playbook.

These variables **must** be set in a common variables file if you do not wish to use defaults.

<!--TOC-->
<!--ENDTOC-->

<!--ROLEVARS-->
## Default variables
```yaml
---
# Common defaults - the "_init" role is mandatory so this will ensure defaults to other roles too.
deploy_user: deploy # if you are using ce-provision to deploy infrastructure this must match the `user_deploy.username` variable
# For MySQL CE you might want to add '--set-gtid-purged=OFF --skip-definer' here:
_mysqldump_params: "--max-allowed-packet=128M --single-transaction --skip-opt -e --quick --skip-disable-keys --skip-add-locks -C -a --add-drop-table"
# @TODO only used by Drupal 7, can be removed with Drupal 7 deployments
bin_directory: "/home/{{ deploy_user }}/.bin"
install_php_cachetool: true # set to false if you don't need cachetool, e.g. for a nodejs app
ce_deploy_version: 1.x
ce_provision_version: 2.x # the version of ce-provision to grab files from when roles are shared
lock_file: /tmp/ce-deploy-lock
provision_lock_file: /tmp/ce-provision-lock # must match _init.lock_file in ce-provision
skip_build_path_check: false # by default we're checking if track number matches
# Application specific variables.
drupal:
  drush_verbose_output: false
  truncate_cache_table: false # when set to true - truncate database table cache_container, a workaround to resolve the 'Cannot redeclare ...' error
  sites:
    - folder: "default"
      public_files: "sites/default/files"
      # Drupal 8 variables
      config_sync_directory: "config/sync"
      config_import_command: "" # i.e. "cim" - set this to "deploy" and cache rebuild and db updates will be skipped
      # End Drupal 8 variables
      # Drupal 7 variables
      revert_features_command: "" # i.e. "fra"
      revert_ctools_command: "ctools-export-revert --all"
      # End Drupal 7 variables
      sanitize_command: "sql-sanitize"
      base_url: https://www.example.com
      force_install: false
      install_command: "-y si"
      cron:
        - minute: "*/{{ 10 | random(start=1) }}"
          job: cron
      feature_branch: false # whether or not this build is a feature branch that should sync assets from another environment
      # For syncing database and files on a feature branch initial build - include all variables if used:
      mysql_sync: {} # see sync/database_sync for docs
      #  mysqldump_params: "{{ _mysqldump_params }}"
      #  cleanup: true
      #  archival_method: gzip
      #  databases: []
      files_sync: {} # see sync/files_sync for docs
      #  unique_workspace: false
      #  cleanup: true
      #  directories: []
mautic:
  image_path: "media/images"
  force_install: false

```

<!--ENDROLEVARS-->
