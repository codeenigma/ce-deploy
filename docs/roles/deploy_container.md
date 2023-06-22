# Deploy container
Step that deploys the codebase in a Docker container image.

<!--TOC-->
<!--ENDTOC-->

<!--ROLEVARS-->
## Default variables
```yaml
---
deploy_container:
  container_name: "example/example"
  container_tag: latest # tag will take format container_name:container_tag
  docker_registry_url: https://index.docker.io/v1/
  docker_registry_user: example
  docker_registry_pass: asdf1234
  docker_base_command: "docker image build"
  docker_build_dir: "{{ _ce_deploy_build_dir }}"
  environment_vars: {} # dictionary you can populate for use in a custom Dockerfile template   
  # Requires the deploy IAM user to have the managed EC2InstanceProfileForImageBuilderECRContainerBuilds policy attached
  aws_ecr:
    enabled: false # set to true if using AWS ECR
    region: eu-west-1
    profile: example

```

<!--ENDROLEVARS-->
