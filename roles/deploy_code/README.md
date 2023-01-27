# Deploy
Step that deploys the codebase. On standalone machines and "static" clusters of web servers (e.g. machines whose addressing never changes) this is reasonably straightforward, the default variables should "just work". This role also supports deployment to autoscaling clusters of web servers, such as AWS autoscaling groups or containerised architecture. More details on that after this section.

The shell script that wraps Ansible to handle the various build steps has various "stages" and the `deploy_code` role has a set of tasks for each stage. The key one for code building on the static/current cluster servers is [the `deploy.yml` file](https://github.com/codeenigma/ce-deploy/blob/1.x/roles/deploy_code/tasks/deploy.yml). Here you will find the steps for checking out and building code on web servers, as well as the loading in of any application specific deploy code, [e.g. these tasks for Drupal 8](https://github.com/codeenigma/ce-deploy/tree/1.x/roles/deploy_code/deploy_code-drupal8/tasks). You choose what extra tasks to load via the `project_type` variable. Current core options are:

* `drupal7`
* `drupal8`
* `matomo`
* `mautic`
* `simplesamlphp`

Patches to support other common applications are always welcome! Also, Ansible inheritance being what it is, you can create your own custom deploy role in the same directory as your deployment playbook and Ansible will detect it and make it available to you. For example, if you create `./roles/deploy_code/deploy_code-myapp/tasks/main.yml` relative to your playbook and set `project_type: myapp` in your project variables then `ce-deploy` will load in those tasks.

# Autoscale deployment
For autoscaling clusters - no matter the underlying tech - the build code needs to be stored somewhere central and accessible to any potential new servers in the cluster. Because the performance of network attached storage (NAS) is often too poor or unreliable, we do not deploy the code to NAS - although this would be the simplest approach. Instead the technique we use is to build the code on each current server in the cluster, as though it were a static cluster or standalone machine, but *also* copy the code to the NAS so it is available to all future machines. This makes the existence of mounted NAS that is attached to all new servers a pre-requisite for `ce-deploy` to work with autoscaling.

**Important**, autoscale deployments need to be carefully co-ordinated with [the `mount_sync` role in `ce-provision`](https://github.com/codeenigma/ce-provision/tree/1.x/roles/mount_sync) so new servers/containers have the correct scripts in place to place their code after they initialise. Specifically, the `mount_sync.tarballs` or `mount_sync.squashed_fs` list variables in `ce-provision` must contain paths that match with the location specified in the `deploy_code.mount_sync` variable in `ce-deploy` so `ce-deploy` copies code to the place `ce-provision`'s `cloud-init` scripts expect to find it. (More on the use of `cloud-init` below.)

(An aside, we have previously supported S3-like object storage for storing the built code, but given all the applications we work with need to have NAS anyway for end user file uploads and other shared cluster resources, it seems pointless to introduce a second storage mechanism when we have one there already that works just fine.)

This packaging of a copy of the code all happens in [the `cleanup.yml` file of the role](https://github.com/codeenigma/ce-deploy/blob/1.x/roles/deploy_code/tasks/cleanup.yml). It supports three options:

* No autoscale (or AWS AMI-based autoscale - see below) - leave `mount_sync` as an empty string
* `tarball` type - makes a `tar.gz` with the code in and copies it to the NAS
* `squashfs` type - packs a [`squashfs`](https://github.com/plougher/squashfs-tools) image, copies to the NAS and mounts it on each web server

For both `tarball` and `squashfs` you need to set `mount_type` accordingly and the `mount_sync` variable to the location on your NAS where you want to store the built code.

## `tarball` builds
This is the simplest method of autoscale deployment, it simply packs up the code and copies it to the NAS at the end of the deployment. Everything else is just a standard "normal" build.

**Important**, this method is only appropriate if you do not have too many files to deploy. The packing and restoring takes a very long time if there are many small files, so it is not appropriate for things like `composer` built PHP applications.

### Rolling back
With this method the live code directory is also the build directory, therefore you can edit the code in place in an emergency and "rolling back" if there are issues with a build is just a case of pointing the live build symlink back to the previous build. As long as the `database_backup` is using the `rolling` method then the "roll back" database will still exist and the credentials will be correct in the application. If the backup is `dump` then you will need to inspect [the `mysql_backup.dumps_directory` variable](https://github.com/codeenigma/ce-deploy/blob/1.x/roles/database_backup/database_backup-mysql/defaults/main.yml#L4) to see where the backup was saved in order to restore it. By default this will be on the NAS so it is available to all web servers.

## `squashfs` builds
Because `tarball` is very slow, we have a second method using [`squashfs`](https://github.com/plougher/squashfs-tools). This filesystem is designed for packing and compressing files into read-only images - initially to deploy to removable media - that can simply be mounted, similar to a macOS Apple Disk Image (DWG) file. It is both faster to pack than a tarball *and* instant to deploy (it's just a `mount` command).

However, the build process is more complex. Because mounted `squashfs` images are read only, we cannot build over them as we do in other types of build. [We alter the build path variables in the `_init` role](https://github.com/codeenigma/ce-deploy/blob/1.x/roles/_init/tasks/main.yml#L25) so the build happens in a separate place and then in the `cleanup.yml` we pack the built code into an image ready to be deployed. Again, because the images are read-only mounts, the live site needs to be *unmounted* with an `umount` command and then remounted with a `mount` command to be completely deployed. This requires the `ce-deploy` user to have extra `sudo` permissions, which is handled by [the `mount_sync` role in `ce-provision`](https://github.com/codeenigma/ce-provision/tree/1.x/roles/mount_sync)

Consequently, at the build stage there are two important extra variables to set:

```yaml
deploy_code:
  # List of services to manipulate to free the loop device for 'squashfs' builds, post lazy umount.
  # @see the squashfs role in ce-provision where special permissions for deploy user to manipulate services get granted.
  services: []
  # services:
  #   - php8.0-fpm
  # What action to take against the services, 'reload' or 'stop'.
  # Busy websites will require a hard stop of services to achieve the umount command.
  service_action: reload
```

`services` is a list of Linux services to stop/reload in order to ensure the mount point is not locked. Usually this will be your PHP service, e.g.

```yaml
deploy_code:
  services:
    - php8.1-fpm
```

`service_action` is whether `ce-deploy` should restart the services in the list of stop them, unmount and remount the image and start them again. The latter is the only "safe" way to deploy, but results in a second or two of down time.

Finally, as with the `tarball` method, the packed image is copied up to the NAS to be available to all future servers and is always named `deploy.sqsh`. The previous codebase is *also* packed and copied to the NAS, named `deploy_previous.sqsh` in the same directory.

### Rolling back
Rolling back from a bad `squashfs` build means copying `deploy_previous.sqsh` down from the NAS to a sensible location in the `ce-deploy` user's home directory, unmounting the current image and mounting `deploy_previous.sqsh` in its place. Once you've done that, to ensure future autoscaling events do not load the bad code, on the NAS you will need to rename `deploy.sqsh` to something else (or delete it entirely if you're sure you don't want it) and rename `deploy_previous.sqsh` as `deploy.sqsh`, so it is used on an autoscale event.

Same as with the `tarball` method, as long as the `database_backup` is using the `rolling` method then the "roll back" database will still exist and the credentials will be correct in the `deploy_previous.sqsh` image. Again, if the backup method is `dump` then you will need to inspect [the `mysql_backup.dumps_directory` variable](https://github.com/codeenigma/ce-deploy/blob/1.x/roles/database_backup/database_backup-mysql/defaults/main.yml#L4) to see where the backup was saved in order to restore it.

Emergency code changes are possible but more fiddly. You have to copy the codebase from the mount to a sensible, *writeable* location, make your changes, [use the `squashfs` command to pack a new image](https://github.com/codeenigma/ce-deploy/blob/1.x/roles/deploy_code/tasks/cleanup.yml#L54), mount that image and, crucially, replace the `deploy.sqsh` image file on the NAS with your new image so future autoscale events will pick it up.

# Autoscaling events
Deploying code with autoscaling clusters relies on [cloud-init](https://cloudinit.readthedocs.io/) and is managed in our stack by [the `mount_sync` role in `ce-provision`](https://github.com/codeenigma/ce-provision/tree/1.x/roles/mount_sync). Whenever a new server spins up in a cluster, the `cloud-init` run-once script put in place by `ce-provision` is executed and that copies down the code from the NAS and deploys it to the correct location on the new server. At that point the server should become "healthy" and start serving the application.

# AMI-based autoscale
**This is experimental.** We are heavily based on [GitLab CE](https://gitlab.com/rluna-gitlab/gitlab-ce) and one of the options we support with [our provisioning tools](https://github.com/codeenigma/ce-provision/tree/1.x) is packing an [AWS AMI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html) with the code embedded within, thus no longer requiring the [cloud-init](https://cloudinit.readthedocs.io/) step at all. [We call this option `repack` and the code is here.](https://github.com/codeenigma/ce-provision/blob/1.x/roles/aws/aws_ami/tasks/repack.yml) This makes provisioning of new machines in a cluster a little faster than the `squashfs` option, but requires the ability to trigger a build on our infrastructure `controller` server to execute a cluster build and pack the AMI. That is what the `api_call` dictionary below is providing for. You can see the API call constructed in [the last task of `cleanup.yml`](https://github.com/codeenigma/ce-deploy/blob/1.x/roles/deploy_code/tasks/cleanup.yml#L205).

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
  # create: whether to create the target if it does not exists.
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
  # Whether to sync the local deploy base to a shared destination, after successful build.
  mount_sync: ""
  # mount_sync: "/home/{{ deploy_user }}/shared/{{ project_name }}_{{ build_type }}/deploy"
  # Type of file to use for sync - 'squashfs' or 'tarball'
  # @see the _init role for SquashFS build dir paths
  # @see the squashfs role in ce-provision which installs the special conditions required by the deploy user to use this behaviour
  mount_type: "tarball"
  # Path that you want to make sure has 755 permissions. Make sure to include the webroot WITHOUT the slash.
  perms_fix_path: ""
  # perms_fix_path: "www/sites/default"
  # List of services to manipulate to free the loop device for 'squashfs' builds, post lazy umount.
  # @see the squashfs role in ce-provision where special permissions for deploy user to manipulate services get granted.
  services: []
  # services:
  #   - php8.0-fpm
  # What action to take against the services, 'reload' or 'stop'.
  # Busy websites will require a hard stop of services to achieve the umount command.
  service_action: reload
  # Trigger an API call to rebuild infra after a deploy, e.g. if you need to repack an AMI.
  rebuild_infra: false
  # Details of API call to trigger. See api_call role.
  api_call:
    type: gitlab
    base_url: https://gitlab.example.com/api/v4/
    path: projects/1/ref/main/trigger/pipeline
    method: POST
    token: asdf-1234
    token_type: trigger
    variables: []
    # example build parameters
    #  - "[ENV]=dev"
    #  - "[PLAY]=myserver.yml"
    #  - "[RESOURCE]=myserver-example-com"
    #  - "[REGION]=eu-west-1"
    #  - "[EXTRA_PARAMS]=--force"
    status_codes:
      - 200
      - 201
      - 202

```

<!--ENDROLEVARS-->
