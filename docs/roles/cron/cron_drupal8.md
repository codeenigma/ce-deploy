# Drupal 8 cron

Ensure Drupal cron entries are run.

<!--ROLEVARS-->
## Default variables
```yaml
---
# This role takes its parameters from the "drupal.sites" variables directly.
drupal:
  sites:
    - folder: "default"
      # ... See the _init role for other variables.
      cron: # These are the relevant parts for cron.
        - minute: "*/{{ 10 | random(start=1) }}"
          # hour: 2
          job: cron

```

<!--ENDROLEVARS-->

<!--TOC-->
<!--ENDTOC-->
