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
  # Number of builds to keep. Note this is independant of databases/dump.
  keep: 10
  # Wether to sync the local deploy base to a shared destination, after successful build.
  mount_sync: false
  mount_sync_tarball: /mnt/directory/project.tar

```

<!--ENDROLEVARS-->
