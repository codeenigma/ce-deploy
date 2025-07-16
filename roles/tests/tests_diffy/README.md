# Diffy tests
[Diffy](https://diffy.website/) is a visual regression tool for PHP, predominantly used with WordPress and Drupal.

In Diffy you must have created a project, set at least one environment up that Diffy can use as a benchmark (role default is `dev`) and provided Diffy with a set of URLs to test. For example:

```yaml
---
diffy:
  main_env: dev
  test_env: custom
  test_env_url: http://my-feature-branch.example.com
```

In this case you have pre-configured an environment called `dev` in Diffy and given it some test URLs to execute. Diffy will run the tests against the `dev` environment, then it will test the same paths against whatever site it finds at `http://my-feature-branch.example.com`. You will then get a report comparing the two sites and highlighting any differences.

<!--TOC-->
<!--ENDTOC-->

<!--ROLEVARS-->
## Default variables
```yaml
---
diffy:
  install: false  # set to true if you want ce-deploy to attempt to composer install diffy
  key: asdfghjkl  # set your diffy secret key, this should be encrypted with SOPS or stored in some other secrets manager
  project_id: 1   # the numeric ID of your diffy project
  main_env: dev   # name of the 'good' environment to compare against (must be pre-configured in diffy)
  test_env: custom  # name of the environment to be compared (usually diffy's default 'custom' environment)
  test_env_url: ""  # set a base URL to use against the diffy 'custom' environment
  bin: "{{ live_symlink_dest }}/vendor/bin/diffy"  # location of diffy
  working_dir: "{{ live_symlink_dest }}"  # path to execute composer and related binaries from

```

<!--ENDROLEVARS-->
