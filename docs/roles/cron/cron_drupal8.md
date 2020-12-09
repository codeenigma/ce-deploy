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
  # If the sites are being deployed to an ASG, setting defer to true will create the crontab entry on the deploy server rather than all of the app servers.
  defer: false
  # If defer is set to true, the Ansible target must be declared with defer_target. If using a group, include the index. For example, _ce_www_dev[0]
  defer_target: ""

```

<!--ENDROLEVARS-->

<!--TOC-->
<!--ENDTOC-->
