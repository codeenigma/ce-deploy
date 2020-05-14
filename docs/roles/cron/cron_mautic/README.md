# Mautic cron tasks
Ensure Mautic cron entries are run.
<!--ROLEVARS-->
## Default variables
```yaml
---
cron_mautic:
entries:
- minute: "*/{{ 10 | random }}"
job: mautic:segments:update
- minute: "*/{{ 15 | random }}"
job: mautic:campaigns:update
- minute: "*/{{ 10 | random }}"
# hour: 4
job: mautic:campaigns:trigger
```

<!--ENDROLEVARS-->

<!--TOC-->
<!--ENDTOC-->
