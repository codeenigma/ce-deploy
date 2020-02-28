# Composer
Performs a composer install on a freshly deployed codebase.
<!--ROLEVARS-->
## Default variables
```yaml
---
composer:
command: install
no_dev: yes
working_dir: "{{ deploy_path }}"
apcu_autoloader: yes
```

<!--ENDROLEVARS-->
