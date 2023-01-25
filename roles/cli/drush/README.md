# Drush
Installs the `drush` command-line tool for the deploy user. **This only works with Drupal 7** and will be withdrawn with [Drupal 7 EOL](https://www.drupal.org/psa-2022-02-23).

For Drupal 8 and above you must install `drush` with `composer` [as described in the `drush`  documentation](https://www.drush.org/latest/install/).

<!--ROLEVARS-->
## Default variables
```yaml
---
drush:
  # Where possible always load drush in your Drupal website with composer.
  version: 8.4.11
  use_vendor: false
```

<!--ENDROLEVARS-->
