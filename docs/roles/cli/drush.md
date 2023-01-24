# Drush
Installs the `drush` command-line tool for the deploy user. Note, support for `drush` version 8 and below will be withdrawn with [Drupal 7 EOL](https://www.drupal.org/psa-2022-02-23).

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
