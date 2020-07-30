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
    - minute: "{{ 50 | random(start=40) }}"
      job: mautic:social:monitoring
    - minute: "{{ 40 | random(start=30) }}"
      job: mautic:emails:send
    - minute: "*/{{ 15 | random(start=1) }}"
      job: mautic:import

```

<!--ENDROLEVARS-->

<!--TOC-->
<!--ENDTOC-->
