# Database backup cron task - MySQL
Ensure regular local backups of MySQL databases.
<!--ROLEVARS-->
## Default variables
```yaml
---
cron_mysql_backup:
  dumps_directory: "/home/{{ deploy_user }}/db_backups/mysql/regular/{{ project_name }}/{{ build_type }}"
  keep: 10
```

<!--ENDROLEVARS-->

<!--TOC-->
<!--ENDTOC-->
