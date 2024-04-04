# Maintenance Mode
This role and its sub-roles handle various methods for putting applications into an offline maintenance state. See each sub-role's own defaults for additional variables.

<!--TOC-->
<!--ENDTOC-->

<!--ROLEVARS-->
## Default variables
```yaml
---
# Puts site(s) offline.
maintenance_mode:
  # What level do we operate.
  # - nginx: serves a static maintenance page.
  # - drupal_core: application level
  # - mautic: application level
  # @todo - haproxy: serves a static maintenance page.
  # @todo - drupal_read_only: application level via readonly module.
  mode: "nginx"
  # - offline: puts the site offline
  # @todo - restricted: put the site offline except for whitelist (nginx/haproxy only)
  # - online: brings the site back online.
  operation: "offline"
```

<!--ENDROLEVARS-->
