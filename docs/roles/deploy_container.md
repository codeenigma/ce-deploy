# Deploy container
Step that deploys the codebase in a Docker container image. Requires Docker and the `community.docker` collection for Ansible to be installed on your deploy server. You will also need to add a `docker` group and make sure your local deploy user is in that group, for example:

```
sudo groupadd docker
sudo usermod -aG docker deploy
```

This can be handled automatically by [`ce-provision`](https://github.com/codeenigma/ce-provision) using the `ce_deploy` and `docker_ce` roles.

If you set the `deploy_container.action` to `destroy` then the role will also take care of tidying up containers. If it is an AWS ECS deployment then it will also tidy up the ECS service for you.

## AWS IAM requirements
AWS integration requires the AWS CLI user provided for `ce-deploy` to have certain managed AWS policies attached.

If you enable AWS ECR registry integration by setting `deploy_container.aws_ecr.enabled` to `true` then you will need the `EC2InstanceProfileForImageBuilderECRContainerBuilds` policy attached via IAM to allow access to fetch credentials and push containers.

Similarly, if you set `deploy_container.aws_ecs.acm.create_cert` to `true` then you will need the `AWSCertificateManagerFullAccess` policy attaching to create SSL certificates.

If you enable full AWS ECS integration by setting `deploy_container.aws_ecs.enabled` to `true` then this requires the following policies to be attached to the AWS CLI user:
* `AmazonECS_FullAccess` - to create task definitions and services
* `ElasticLoadBalancingFullAccess` - to create load balancers and target groups

Finally, if you set `deploy_container.aws_ecs.route_53.zone` to another other than an empty string then you will also need `AmazonRoute53FullAccess` attaching to manipulate DNS entries in Route 53.

The full list is:
* `EC2InstanceProfileForImageBuilderECRContainerBuilds` - to manipulate images in AWS ECR
* `AWSCertificateManagerFullAccess` - to manage SSL certificates
* `AmazonECS_FullAccess` - to create task definitions and services
* `ElasticLoadBalancingFullAccess` - to create load balancers and target groups
* `AmazonRoute53FullAccess` - to manage DNS entries

Naturally you can always create custom policies and roles to have tighter access control. This document simply gives you the broad strokes AWS managed policies you can use in conjunction with this Ansible role.

# Peculiarities of AWS ECS
It is worth noting that even if you put your containers on private subnets and configure your apps to use internal addressing, traffic will pass via the public interface. Therefore any safelisting of IP addresses needs to include the IP addresses of the NAT gateways of your private subnets. [More on how this works here.](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/networking-connecting-vpc.html)

<!--TOC-->
<!--ENDTOC-->

<!--ROLEVARS-->
## Default variables
```yaml
---
deploy_container:
  action: create # can also be destroy
  container_name: example-container
  container_tag: latest # tag will take format container_name:container_tag
  container_force_build: true # force Docker to build and tag a new image
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
    aws_profile: example
  # Requires the deploy IAM user to have the managed AmazonECS_FullAccess and ElasticLoadBalancingFullAccess policies attached
  # Note, you can if you wish make more restrictive roles and policies
  aws_ecs:
    enabled: false
    region: eu-west-1
    aws_profile: example
    tags: {}
    domain_name: www.example.com
    route_53:
      zone: example.com
      aws_profile: example2 # might not be the same account
    vpc_name: example
    #vpc_id: vpc-XXXXXXX # optionally specify VPC ID to use
    security_groups: [] # list of security groups, accepts names or IDs
    cluster_name: example-cluster
    family_name: example-task-definition
    task_definition_revision: "" # integer, but must be presented as a string for Jinja2
    task_definition_force_create: false # creates a task definition revision every time if set to true
    task_execution_role_arn: "arn:aws:iam::000000000000:role/ecsTaskExecutionRole" # ARN of the IAM role to run the task as, must have access to the ECR repository if applicable
    #task_role_arn: "" # required if you set service_enable_ssm to true
    task_count: 1
    task_minimum_count: 1
    task_maximum_count: 4
    # These subnets are usually the subnets created by ce-provision when you made your ECS cluster and must have a NAT gateway for ECR access.
    service_subnets: # list of private subnet names
      - example-cluster-dev-a
      - example-cluster-dev-b
    # See docs for values: https://docs.aws.amazon.com/autoscaling/application/APIReference/API_TargetTrackingScalingPolicyConfiguration.html
    service_autoscale_metric_type: ECSServiceAverageCPUUtilization
    service_autoscale_up_cooldown: 120
    service_autoscale_down_cooldown: 120
    service_autoscale_target_value: 70 # the value to trigger a scaling event at
    service_public_container_ip: false # set to true to make containers appear on an EIP - more details: https://stackoverflow.com/a/66802973
    service_enable_ssm: false # set to true to allow arbitrary command execution on containers via the AWS API
    service_force_refresh: false # forces a refresh of all containers if set to true
    containers: # list of container definitions, see docs: https://docs.ansible.com/ansible/latest/collections/community/aws/ecs_taskdefinition_module.html#parameter-containers
      - name: example-container
        essential: true
        image: index.docker.io/example:latest
        portMappings:
          - containerPort: 8080 # should match target_group_port
            hostPort: 8080
        logConfiguration:
          logDriver: awslogs
          options:
            awslogs-group: /ecs/example-cluster
            awslogs-region: eu-west-1
            awslogs-stream-prefix: "ecs-example-task"
    cpu: 512 # these values can be set globally or per container
    memory: 1024
    launch_type: FARGATE
    network_mode: awsvpc
    #volumes: [] # list of additional volumes to attach
    target_group_name: example # can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen
    target_group_protocol: http
    target_group_port: 8080 # ports lower than 1024 will require the app to be configured to run as a privileged user in the Dockerfile
    target_group_wait_timeout: 200 # how long to wait for target group events to complete
    targets: [] # typically we do not specify targets at this point, this will be handled automatically by the ECS service
      #- Id: 10.0.0.2
      #  Port: 80
      #  AvailabilityZone: all
    health_check:
      protocol: http
      path: /
      response_codes: "200"
    # Requires the deploy IAM user to have the managed AWSCertificateManagerFullAccess and AmazonRoute53FullAccess policies attached
    acm: # see https://github.com/codeenigma/ce-provision/tree/1.x/roles/aws/aws_acm
      create_cert: false
      extra_domains: [] # list of Subject Alternative Name domains and zones
    ssl_certificate_ARN: "" # optional SSL cert ARN if you imported one into AWS Certificate Manager
    elb_security_groups: [] # default SG is used if none provided - module supports names or IDs
    elb_subnets: # must be public subnets for public facing applications
      - example-dev-a
      - example-dev-b
    elb_http_port: 80
    elb_https_port: 443
    elb_ssl_policy: ELBSecurityPolicy-TLS13-1-2-2021-06 # see https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies
    elb_listener_http_rules: []
    elb_listener_https_rules: []
    # Add custom listeners. See https://docs.ansible.com/ansible/latest/collections/amazon/aws/elb_application_lb_module.html
    elb_listeners: []
    elb_idle_timeout: 60
    elb_ip_address_type: "ipv4" # Can be 'ipv4' or 'dualstack' (the latter includes IPv4 and IPv6 addresses).

```

<!--ENDROLEVARS-->
