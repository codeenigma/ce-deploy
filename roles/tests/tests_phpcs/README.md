# PHP CodeSniffer tests
Step that runs [PHP CodeSniffer](https://github.com/PHPCSStandards/PHP_CodeSniffer) against the specified path(s) in the codebase.

Optionally installs PHP CodeSniffer with `composer` using [this package](https://packagist.org/packages/dealerdirect/phpcodesniffer-composer-installer) if you want it to do so. Can also install [the Coder module for Drupal](https://www.drupal.org/project/coder), which provides an installed standard for Drupal.

For more information on PHP CodeSniffer, see the GitHub wiki: https://github.com/PHPCSStandards/PHP_CodeSniffer/wiki/

## Using with Drupal
Ideally to use the role with Drupal you should start with [the Coder module](https://www.drupal.org/project/coder), which means having this in your `composer.json` file:

```json
  "require-dev": {
    "drupal/coder": "^8.3"
  },
  "config": {
    "allow-plugins": {
      "dealerdirect/phpcodesniffer-composer-installer": true
    },
    "sort-packages": true
  }
```

You can then set the Ansible variables as follows to check your custom Drupal themes and modules:

```yaml
---
composer:
  no_dev: false # installs phpcs, phpstan and phpunit - see dependencies: https://packagist.org/packages/drupal/coder
phpcs:
  standard: vendor/drupal/coder/coder_sniffer/Drupal
  extensions: php,module,inc,theme,install
  test_paths:
    - web/themes/custom
    - web/modules/custom
```

## Using with other PHP applications
To load PHP CodeSniffer in another `composer`-based PHP application, this should be sufficient:

```json
  "require-dev": {
    "dealerdirect/phpcodesniffer-composer-installer": "^1.0"
  },
    "config": {
    "allow-plugins": {
      "dealerdirect/phpcodesniffer-composer-installer": true
    },
    "sort-packages": true
  }
```

See the installation documentation on packagist: https://packagist.org/packages/dealerdirect/phpcodesniffer-composer-installer

<!--TOC-->
<!--ENDTOC-->

<!--ROLEVARS-->
## Default variables
```yaml
---
phpcs:
  install: false               # set to true if you want ce-deploy to attempt to composer install PHP CodeSniffer
  install_drupal_coder: false  # set to true to install the Coder module for Drupal, which provides a Drupal standard for CodeSniffer
  bin: "{{ deploy_path }}/vendor/bin/phpcs"  # location of phpcs
  standard: ""    # optionally set the path to an installed standard, for example "vendor/drupal/coder/coder_sniffer/Drupal" for the Coder module for Drupal
  extensions: ""  # set optional extensions, for example for Drupal you could set "php,module,inc,theme,install" - defaults to "php,inc/php,js,css"
  test_paths: []  # list of paths to test against
  working_dir: "{{ deploy_path }}"  # path to execute composer from

```

<!--ENDROLEVARS-->
