# Init
These variables **must** be set in the `deploy/common.yml` file, at least.

<!--TOC-->
<!--ENDTOC-->

<!--ROLEVARS-->
## Default variables
```yaml
---
# Common defaults. Given the "_init" role is mandatory,
# this will ensure defaults to other roles too.
# If you are using ce-provision to deploy infrastructure this must match the `user_deploy.username` variable
deploy_user: "deploy"
# for MySQL CE you might want to add '--set-gtid-purged=OFF --skip-definer' here
_mysqldump_params: "--max-allowed-packet=128M --single-transaction --skip-opt -e --quick --skip-disable-keys --skip-add-locks -C -a --add-drop-table"
drupal:
  drush_verbose_output: false
  # when set to true - truncate database table cache_container, a workaround to resolve the 'Cannot redeclare ...' error.
  truncate_cache_table: false
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
      # For syncing database and files on a feature branch initial build - include all variables if used
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
# Used for custom build time tools like cachetool
bin_directory: "/home/{{ deploy_user }}/.bin"
# Number of dumps/db to look up for cleanup.
cleanup_history_depth: 50
install_php_cachetool: true # set to false if you don't need cachetool, e.g. for a nodejs app

```

<!--ENDROLEVARS-->
