# MySQL backups
Generate MySQL backups for each build.
<!--ROLEVARS-->
## Default variables
```yaml
---
mysql_backup:
  handling: rolling
  dumps_directory: "/home/{{ deploy_user }}/shared/{{ project_name }}_{{ build_type }}/db_backups/mysql/build"
  # Number of dumps/db to keep. Note this is independant from the build codebases.
  keep: 10
  # This can be one of the following:
  # - rotate:
  # Generates a new user/pwd pair per builds.
  # This require that the credentials passed as database.credentials_file have GRANT permissions.
  # - static:
  # Generates a new user/pwd pair only on first build.
  # This require that the credentials passed as database.credentials_file have GRANT permissions.
  # - manual:
  # Uses the same user/pwd pair than the one found in the database.credentials_file.
  # This is useful for locked-down setups where you do not have GRANT permissions.
  credentials_handling: rotate
  databases:
    - database: "{{ project_name }}_{{ build_type }}"
      user: "{{ project_name }}_{{ build_type }}"
      credentials_file: "/home/{{ deploy_user }}/.mysql.creds"

```

<!--ENDROLEVARS-->

<!--TOC-->
<!--ENDTOC-->
