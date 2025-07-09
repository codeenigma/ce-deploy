# Behat tests
[Behat](https://behat.org/) is an open source [Behaviour Driven Development](https://en.wikipedia.org/wiki/Behavior-driven_development) tool for building software that is often used for functional testing.

<!--TOC-->
<!--ENDTOC-->

<!--ROLEVARS-->
## Default variables
```yaml
---
behat:
  install: false        # set to true if you want ce-deploy to attempt to composer install Behat
  tags: "~@javascript"  # behat tags to run
  verbose: false        # set to true for verbose output
  bin: "{{ deploy_path }}/vendor/bin/behat"  # location of Behat
  # List of outputs to create, defaults to 'pretty' to STDOUT
  outputs:
    - format: pretty  # options are pretty, progress or junit
      output: std     # see docs for more information, supports output filepath or various formats
  config_file: "{{ deploy_path }}/tests/behat/behat.yml"  # path to config file
  working_dir: "{{ deploy_path }}"  # path to execute composer from

```

<!--ENDROLEVARS-->
