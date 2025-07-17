# Opcache

Clear opcache. You must have run the `cli/cachetool` role to install `cachetool` first.

<!--TOC-->
<!--ENDTOC-->

<!--ROLEVARS-->
## Default variables
```yaml
---
cache_clear_opcache:
  # Bins to clear.
  clear_opcache: true
  clear_apcu: false
  clear_stat: true
  # cachetool_bin: "/path/to/cachetool.phar"  # see _init for default paths if undefined

```

<!--ENDROLEVARS-->
