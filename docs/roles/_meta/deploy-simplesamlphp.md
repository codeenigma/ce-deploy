# SimpleSAMLphp
Role for deploying single SimpleSAMLphp instances. Do not use if you are deploying SimpleSAMLphp with another application like Drupal via composer.

This role currently assumes all config is in the repository alongside composer.json and the special `SIMPLESAMLPHP_CONFIG_DIR` variable is passed in via the web server vhost to tell SimpleSAMLphp where the config is on the server. For vhost configuration in Nginx see ce-provision:

* https://github.com/codeenigma/ce-provision/blob/1.x/roles/nginx

<!--ROLEVARS-->
<!--ENDROLEVARS-->
