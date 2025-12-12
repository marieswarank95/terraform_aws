<!-- Center and Bold Title -->
<p align="center">
<b><h1>🚀Lifecycle🚀</h1></b>
</p>
This meta argument has multiple nested arguments.

1. create_before_destroy
2. prevent_destroy
3. ignore_changes
4. replace_triggered_by
5. pre and post condition

<b><h3>create_before_destroy</h3></b>
Consider an EC2 instance created by Terraform. If you change the AMI ID or subnet ID in the EC2 resource, Terraform cannot update these changes in-place. Instead, it performs a replacement:

1. Destroys the existing resource
2. Creates a new resource


<i>This is Terraform’s default behavior and causes downtime.</i>

<b>Solution:</b> Use the lifecycle meta argument with create_before_destroy:

```
#create_befor_destroy example
resource aws_instance "web_instance" {
    ami = "ami-0c398cb65a93047f2"
    instance_type = var.instance_type
    tags = {
        Name = "Web_Instance"
    }

    lifecycle {
        create_before_destroy = true   # meta argument block
    }
}
```

This creates the new resource first, then destroys the old one — zero downtime.

<b><h3>prevent_destroy</h3></b>
The prevent_destroy meta argument helps avoid accidental deletion of resources. When set to true in a resource block.

```
#prevent destroy example
resource aws_instance "web_instance_1" {
    ami = "ami-0c398cb65a93047f2"
    instance_type = var.instance_type
    tags = {
        Name = "Web_Instance_p"
    }

    lifecycle {
        prevent_destroy = true       # meta argument
    }
}
```

<b>What it protects against:</b>

    1. terraform destroy commands
    2. Resource replacements due to configuration changes

<b>To destroy the resource:</b>

Set prevent_destroy = false and then execute terraform plan / apply

<b>Important Limitation:</b>
If the entire resource block is removed from configuration, prevent_destroy won’t protect it. Terraform compares state vs. configuration — if the resource is missing from config, it will destroy it regardless.

<b><h3>ignore_changes</h3></b>
By default, Terraform maintains the desired state defined in the configuration. If someone changes a resource directly (outside Terraform), Terraform will revert those changes during the next apply.

<b>Scenario:</b> You’ve created an Auto Scaling Group (ASG) with dynamic scaling policies using Terraform. When the scaling policy scales out instances to handle high load, someone runs terraform apply. Terraform detects the “drift” and reverts the ASG back to the original instance count.

<b>Problem:</b> This is not expected — the scaling policy should be allowed to work.

<b>Solution:</b> Use ignore_changes:

```
#ASG creation
resource "aws_autoscaling_group" "web_asg" {
  name = "web-asg"
  min_size = 1
  max_size = 4
  desired_capacity = 1
  launch_template {
    id = aws_launch_template.web_lt.id
    version = "$Latest"
  }
  vpc_zone_identifier = [aws_subnet.app-public-subnet.id]
  lifecycle {
    ignore_changes = [desired_capacity]    # meta argument
  }
}
```

<b><h3>replace_triggered_by</h3></b>
This meta argument helps replace a resource when changes occur in a dependent resource.

<b>Example:</b> When changes are made to the security group, it will recreate the instance.

```
#replace triggered by lifecycle nested argument example
resource "aws_instance" "api-instance" {
  ami = "ami-0c398cb65a93047f2"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  tags = {
    Name = "API-Instance"
  }
  lifecycle {
    replace_triggered_by = [aws_security_group.api-sg]   # meta argument
  }
}
```

<b><h3>Pre and post condition</h3></b>
<b>precondition</b>

This meta argument validates resource configuration before creation. If the condition fails during the plan phase, resource creation is blocked.

Policy Validation Example:
You can use this meta argument for regulations or internal policies. 

For example:

<b>Scenario:</b> In the dev environment, only micro or small instance types are acceptable — not large. If someone specifies a higher instance type in dev, validation fails and resource creation is blocked.

<b>Requirements:</b>
Condition value must be known at plan time.

<b>postcondition</b>
Validates after creation during the apply phase. If the condition fails, Terraform destroys the resource and blocks dependent resources.

<b>Requirements:</b>
Condition can use values known only at apply time.

```
#precondition lifecycle meta argument example
resource "aws_instance" "integration-instance" {
  ami = "ami-0c398cb65a93047f2"
  instance_type = var.instance_type
  associate_public_ip_address = true
  tags = {
    Name = "Integration-instance"
  }
  lifecycle {
    precondition {           # meta argument block
      condition = contains(var.allowed_vm_types, var.instance_type)
      error_message = "The given instance type should be matched with allowed vm types."
    }
  }
}
```

<!-- Center and Bold Title -->
<p align="center">
<b><h1>🚀provider🚀</h1></b>
</p>
This is also a meta argument. You can define multiple provider blocks in the Terraform configuration.


```
#deafult one
provider "aws" {
  region = "us-east-1"
}

Second AWS provider (aliased) – e.g., us-west-2
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
```

<b>Example:</b> AWS as the provider, but one block configured for us-east-1 and another for us-west-2.

If some resources need to use a non-default provider block, use this argument to reference the other provider.

```
syntax

provider = aws.<alias>
```