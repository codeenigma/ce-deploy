# ASG Management
This role should be called in a separate playbook to the rest of the build with the host set as `localhost`, not the target ASG group. The available hosts in the ASG group may change after it has run, so Ansible needs to interogate the ASG host group after this play has run and before building.

In order to manipulate an AWS Autoscaling Group (ASG) your `deploy` user must have an AWS CLI profile for a user with the following IAM permissions:
* `autoscaling:ResumeProcesses`
* `autoscaling:SuspendProcesses`
* `autoscaling:DescribeScalingProcessTypes`
* `autoscaling:DescribeAutoScalingGroups`

Set the `asg_management.name` to the machine name of your ASG in order to automatically suspend and resume autoscaling on build.

<!--TOC-->
<!--ENDTOC-->

<!--ROLEVARS-->
<!--ENDROLEVARS-->
