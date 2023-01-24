# Drush
Installs the `drush` command-line tool for the deploy user. Note, this role only supports `drush` version 9 and above.

<!--ROLEVARS-->
## Default variables
```yaml
---
drush:
  # Note: This is the "default" version,
  # but projects should define theirs in composer.json or in their ce-deploy variables files.
  version: 11.4.0
  use_vendor: false
```

<!--ENDROLEVARS-->
