# NPM

Performs npm or yarn tasks on a freshly deployed codebase.

<!--ROLEVARS-->
## Default variables
```yaml
---
npm:
  # npm/yarn
  executor: npm
  working_dir: "{{ deploy_path }}"
  # A list of commands to execute.
  # eg:
  # - install
  # - build-prod
  commands: []
  # Specify any additional symlink to create, with src (target) and dest (link).
  # src: can be either absolute or relative to the dest (eg. '/var/my_data', '/home/deploy/simplesaml', '../../../myconfig')
  # dest: can only be relative to the root of your repository (eg. 'www/themes/myassets', 'var/cache')
  # force: set to true to create the symlinks in two cases: the source file does not exist but will appear later; the destination exists and is a file.
  #  - src: '/home/{{ deploy_user }}//{{ project_name }}_{{ build_type }}/simplesaml'
  #    dest: 'vendor/simplesamlphp/simplesamlphp/config'
  #    force: true
  #  - src: '/var/simplesaml/etc'
  #    dest: 'vendor/simplesamlphp/simplesamlphp/config'
  #    force: false
  symlinks: []
  # Specify any additional templates to generate, with src (template) and dest (file).
  # src: name of a template, in the "templates" dir relative to your playbook.
  # dest: can only be relative to the root of your repository (eg. 'www/config.php', 'var/mysettings.php')
  templates: []

```

<!--ENDROLEVARS-->
