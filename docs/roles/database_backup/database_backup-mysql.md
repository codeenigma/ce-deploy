# MySQL backups
Generate MySQL backups for each build.

## Replicas
If you are using a read only replica in your application and you need to add it to `databases` in order to have access to the credentials for your app settings, be sure to set the database up in a similar way to this:

```yaml
mysql_backup:
  databases:
    - database: "{{ (project_name + '_' + build_type) | regex_replace('-', '_') }}"
      user: "{{ (project_name + '_' + build_type) | truncate(32, true, '', 0) }}"
      credentials_file: "/home/{{ deploy_user }}/.mysql.creds"
      handling: none # prevents the replica from being backed up
      is_replica: true # tells ce-deploy we are working with a replica, so it will implement a pause
```

<!--ROLEVARS-->
## Default variables
```yaml
---
mysql_backup:
  handling: rolling
  dumps_directory: "/home/{{ deploy_user }}/shared/{{ project_name }}_{{ build_type }}/db_backups/mysql/build"
  mysqldump_params: "{{ _mysqldump_params }}" # set in _init but you can override here
  # Location on deploy server where the generated MySQL password will be stashed - should be temporary storage
  mysql_password_path: "/tmp/.ce-deploy/{{ project_name }}_{{ build_type }}_{{ build_number }}"
  # Uncomment to login with MySQL socket instead of TCP/IP (e.g. for MariaDB after secure set-up)
  #mysql_unix_socket: /run/mysqld/mysqld.sock
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
    - database: "{{ (project_name + '_' + build_type) | regex_replace('-', '_') }}" # avoid hyphens in MySQL database names
      user: "{{ (project_name + '_' + build_type) | truncate(32, true, '', 0) }}" # 32 char limit
      credentials_file: "/home/{{ deploy_user }}/.mysql.creds"
      #handling: none # optional override to the main handling method on a per database basis - must be 'none' for replicas
      #is_replica: true # tell ce-deploy this database is a replica - can only be true, remove/comment out if not required

```

<!--ENDROLEVARS-->

<!--TOC-->
<!--ENDTOC-->
