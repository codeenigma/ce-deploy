# Composer

Performs a composer install on a freshly deployed codebase.

<!--ROLEVARS-->
## Default variables
```yaml
---
composer:
  command: install
  no_dev: true
  working_dir: "{{ deploy_path }}"
  apcu_autoloader: true
  # Specify any additional symlink to create, with src (target) and dest (link).
  # src: can be either absolute or relative to the dest (eg. '/var/my_data', '/home/deploy/simplesaml', '../../../myconfig')
  # dest: can only be relative to the root of your repository (eg. 'www/themes/myassets', 'var/cache')
  # create: wether to create the target if it does not exists.
  #  - src: '/home/{{ deploy_user }}//{{ project_name }}_{{ build_type }}/simplesaml'
  #    dest: 'vendor/simplesamlphp/simplesamlphp/config'
  #  - src: '/var/simplesaml/etc'
  #    dest: 'vendor/simplesamlphp/simplesamlphp/config'
  symlinks: []
```

<!--ENDROLEVARS-->
