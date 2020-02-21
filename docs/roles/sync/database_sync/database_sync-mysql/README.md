# Database sync - MySQL
Sync MySQL databases between environments.
<!--ROLEVARS-->
## Default variables
```yaml
---

mysql_sync:
  databases:
    - source:
        # Name of the database to take a dump from.
        database: "{{ project_name }}_prod"
        # Host that can connect to the database.
        host: "localhost"
        # Creds file on the host.
        credentials_file: "/home/{{ deploy_user }}/.mysql.creds"
        # This can be of types:
        # - rolling: (database backups). In that case we'll need build parameters.@todo
        # - fixed: "fixed" database name
        # - dump: Use an existing dump. In that case, the "database" variable is the absolute file path.@todo
        type: fixed
        # For "rolling builds", so we can compute the database name.
        build_info:
          repo: ""
          branch: "prod"
          build_type: "prod"
      target:
          database: "{{ project_name }}_dev"
          credentials_file: "/home/{{ deploy_user }}/.mysql.creds"
          type: fixed
          # For "rolling builds", so we can compute the database name.
          build_info:
            repo: ""
            branch: "prod"
            build_type: "prod"
```

<!--ENDROLEVARS-->

<!--TOC-->
<!--ENDTOC-->
