# ce-dev prebuild
Prebuild Docker images for re-use in ce-dev locally.
<!--ROLEVARS-->
## Default variables
```yaml
---
ce_dev_prebuild:
  compose_template: ce-dev.compose.yml
  compose_prebuilt_template: ce-dev.compose.prebuilt.yml
  source_registry:
    user: ''
    password: ''
  target_registry:
    user: ''
    password: ''
```

<!--ENDROLEVARS-->

<!--TOC-->
## [Database sync - MySQL](database_sync-mysql/README.md)
Sync MySQL databases between environments.
<!--ENDTOC-->
