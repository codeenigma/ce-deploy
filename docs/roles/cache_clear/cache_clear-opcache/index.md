# Opcache
Clear opcache.
<!--TOC-->
<!--ENDTOC-->

<!--ROLEVARS-->
## Default variables
```yaml
---
cache_clear_opcache:
  # Adapter string to use as argument.
  # eg.
  # --fcgi=127.0.0.1:9000
  # Leave blank to use /etc/cachetool.yml
  adapter: ""
  # Bins to clear.
  clear_opcache: yes
  clear_apcu: no
  clear_stat: no
```

<!--ENDROLEVARS-->
