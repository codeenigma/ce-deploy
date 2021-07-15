# Deploy
Step that deploys the codebase.
<!--TOC-->
<!--ENDTOC-->

<!--ROLEVARS-->
## Default variables
```yaml
---
deploy_code:
  # Specify any additional symlink to create, with src (target) and dest (link).
  # src: can be either absolute or relative to the dest (eg. '/var/my_data', '/home/deploy/simplesaml', '../../../myconfig')
  # dest: can only be relative to the root of your repository (eg. 'www/themes/myassets', 'var/cache')
  # create: wether to create the target if it does not exists.
  #  - src: '/home/{{ deploy_user }}//{{ project_name }}_{{ build_type }}/simplesaml'
  #    dest: 'vendor/simplesamlphp/simplesamlphp/config'
  #  - src: '/var/simplesaml/etc'
  #    dest: 'vendor/simplesamlphp/simplesamlphp/config'
  symlinks: []
  # Specify any additional templates to generate, with src (template) and dest (file).
  # src: name of a template, in the "templates" dir relative to your playbook.
  # dest: can only be relative to the root of your repository (eg. 'www/config.php', 'var/mysettings.php')
  templates: []
  # Number of builds to keep. Note this is independant of databases/dump.
  keep: 10
  # Wether to sync the local deploy base to a shared destination, after successful build.
  mount_sync: ""
  # mount_sync: "/home/{{ deploy_user }}/shared/{{ project_name }}_{{ build_type }}/deploy"
  # Path that you want to make sure has 755 permissions. Make sure to include the webroot WITHOUT the slash.
  perms_fix_path: ""
  # perms_fix_path: "www/sites/default"

```

<!--ENDROLEVARS-->
