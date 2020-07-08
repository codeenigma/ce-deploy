# Mautic cron tasks
Ensure Mautic cron entries are run.
<!--ROLEVARS-->
## Default variables
```yaml
---
cron_mautic:
  entries:
    - minute: "*/{{ 10 | random(start=1) }}"
      job: mautic:segments:update
    - minute: "*/{{ 15 | random(start=1) }}"
      job: mautic:campaigns:update
    - minute: "*/{{ 10 | random(start=1) }}"
      # hour: 4
      job: mautic:campaigns:trigger
    - minute: "*/{{ 15 | random(start=1) }}"
      job: mautic:import
```

<!--ENDROLEVARS-->

<!--TOC-->
<!--ENDTOC-->
