# Deploy container
Step that deploys the codebase in a Docker container image. Requires Docker and the `community.docker` collection for Ansible to be installed on your deploy server. You will also need to add a `docker` group and make sure your local deploy user is in that group, for example:

```
sudo groupadd docker
sudo usermod -aG docker deploy
```

This can be handled automatically by [`ce-provision`](https://github.com/codeenigma/ce-provision) using the `ce_deploy` and `docker_ce` roles.

AWS ECR registries require the AWS CLI user provided for `ce-deploy` to have the managed AWS `EC2InstanceProfileForImageBuilderECRContainerBuilds` policy attached via IAM to allow access to fetch credentials and push containers.

<!--TOC-->
<!--ENDTOC-->

<!--ROLEVARS-->
## Default variables
```yaml
---
deploy_container:
  container_name: example
  container_tag: latest # tag will take format container_name:container_tag
  docker_registry_name: index.docker.io/example # combines with container_name to make the full registry name, docker_registry_name/container_name
  docker_registry_user: example
  docker_registry_pass: asdf1234
  docker_base_command: "docker image build"
  docker_build_dir: "{{ _ce_deploy_build_dir }}"
  dockerfile_template: example.j2 # provide a templates directory next to your playbook and change this to match your Dockerfile template name
  environment_vars: {} # dictionary you can populate for use in a custom Dockerfile template   
  # Requires the deploy IAM user to have the managed EC2InstanceProfileForImageBuilderECRContainerBuilds policy attached
  aws_ecr:
    enabled: false # set to true if using AWS ECR
    region: eu-west-1
    profile: example

```

<!--ENDROLEVARS-->
