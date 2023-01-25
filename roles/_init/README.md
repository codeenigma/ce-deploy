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
_mysqldump_params: "--max-allowed-packet=128M --single-transaction --skip-opt -e --quick --skip-disable-keys --skip-add-locks -C -a --add-drop-table"
drupal:
  sites:
    - folder: "default"
      public_files: "sites/default/files"
      # Drupal 8 variables
      config_sync_directory: "config/sync"
      config_import_command: "" # i.e. "cim" - set this to "deploy" and cache rebuild and db updates will be skipped
      # End Drupal 8 variables
      # Drupal 7 variables
      revert_features_command: "" # i.e. "fra"
      # End Drupal 7 variables
      sanitize_command: "sql-sanitize"
      base_url: https://www.example.com
      force_install: false
      install_command: "-y si"
      cron:
        - minute: "*/{{ 10 | random(start=1) }}"
          job: cron
mautic:
  image_path: "media/images"
  force_install: false
bin_directory: "/home/{{ deploy_user }}/.bin"
```

<!--ENDROLEVARS-->
