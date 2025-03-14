# PHPUnit tests
Step that runs PHPUnit against the specified path in the codebase. Requires `composer` and that you provide a `phpunit.xml` config file in one of the following locations:
* `files/phpunit.xml` relative to your playbook
* in the repository root
* in your application's `webroot` directory

As a final fallback it checks for Drupal's default PHPUnit configuration file at `web/core/phpunit.xml.dist`.

For more information on PHPUnit, see https://docs.phpunit.de

<!--TOC-->
<!--ENDTOC-->

<!--ROLEVARS-->
## Default variables
```yaml
---
phpunit:
  group: unit # comma separated list of group names to run
  target: web/modules # directory or file to test, defaults to Drupal's modules directory
  bin: "{{ deploy_path }}/vendor/bin/phpunit" # location of phpunit

```

<!--ENDROLEVARS-->
