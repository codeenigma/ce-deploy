# Database backup cron task - MySQL
Ensure regular local backups of MySQL databases.
<!--ROLEVARS-->
## Default variables
```yaml
---
cron_mysql_backup:
  dumps_directory: "/home/{{ deploy_user }}/shared/{{ project_name }}_{{ build_type }}/db_backups/mysql/regular"
  keep: 10

```

<!--ENDROLEVARS-->

<!--TOC-->
<!--ENDTOC-->
