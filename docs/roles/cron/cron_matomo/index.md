# Database backup cron task - MySQL
Ensure regular local backups of MySQL databases.
<!--ROLEVARS-->
## Default variables
```yaml
---
cron_matomo:
  url: "https://example.com/matomo"
  log_directory: "/home/{{ deploy_user }}/matomo-archive/{{ project_name }}_{{ build_type }}"
  keep: 10
```

<!--ENDROLEVARS-->

<!--TOC-->
<!--ENDTOC-->
