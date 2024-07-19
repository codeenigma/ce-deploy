# Ansible Plugins
This directory contains extra plugins for Ansible.

## Vars plugins
Here we include a plugin for handling SOPS decryption.

## Callback plugins
Here we have a small custom override that fails builds if there are no matching hosts found, to avoid `ce-deploy` incrementing the track file when it didn't actually run because of a host issue.

## Enabling plugins
To use these plugins you need to find the `# set plugin path directories here` section of `ansible.cfg` which should be kept in your `ce-deploy-config` repository. Add the paths to the plugin directories to enable the plugins, e.g.

```
vars_plugins     = /home/deploy/ce-deploy/plugins/vars:/usr/share/ansible/plugins/vars
callback_plugins = /home/deploy/ce-deploy/plugins/callback:/usr/share/ansible/plugins/callback
```
