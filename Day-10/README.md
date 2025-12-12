<!-- Center and Bold Title -->
<p align="center">
<b><h1>Terraform expressions</h1></b>
</p>

We will explore terraform expressions.

    1. Conditional expression
    2. Dynamic block
    3. Splat expression


<b><h3>Conditional expression</h3></b>
It checks conditions to determine whether to create a resource from the resource block or select different configurations, depending on where the condition is used.

```
Syntax

condition ? True value : False value
```

```
variable "environment" {
    type = string
    default = "Development"
}

#conditional expression example
resource "aws_instance" "web" {
    ami = "ami-0c398cb65a93047f2"
    associate_public_ip_address = true
    instance_type = var.environment != "Production" ? "t2.micro" : "t2.small"
    tags = local.tags 
}

resource "aws_instance" "web_instance_1" {
    count = contains(var.allowed_vm_types, var.instance_type) ? var.instance_count : 0  # contains -> function -> syntax contains(list or set, actual given value)
    ami = "ami-0ecb62995f68bb549"
    instance_type = var.instance_type
    monitoring = var.monitoring_enabled
    associate_public_ip_address = var.associate_public_ip
    tags = {
        Name = "web_server"
        Environment = var.environment
    }
}
```

<b><h3>Dynamic block</h3></b>
It enables dynamic creation of nested blocks. Instead of writing multiple nested blocks in the resource, use dynamic blocks with variables tailored to your needs. The for_each meta-argument in the dynamic block iterates through the provided values one by one, constructing nested blocks from each iterated element.

Syntax: (this is prepared based on my example)

```
dynamic label_name {
    for_each = iteratable_element  # this example for list(object)
    content {
        from_port = label_name.value.key # used this for list(object) key -> return index, value -> return actual element value
        to_port = label_name.value.key
        protocol = label_name.value.key
        cidr_blocks = [label_name.value.key]
    }
}
```

In this syntax label_name inside the content block it act like variable for iterated element.

We can take security group example,

```
variable "inbound_rules" {
    type = list(object({from_port = number, to_port = number, protocol = string, source = string}))
    default = [{from_port = 80, to_port = 80, protocol = "tcp", source = "0.0.0.0/0"}, {from_port = 443, to_port = 443, protocol = "tcp", source = "0.0.0.0/0"}]
}

#Dynamic block example
resource "aws_security_group" "web-sg" {
    name = "web-sg"
    description = "sg for web app instance."
    dynamic "ingress" {
        for_each = var.inbound_rules
        content {
            from_port = ingress.value.from_port
            to_port = ingress.value.to_port
            protocol = ingress.value.protocol
            cidr_blocks = [ingress.value.source]
        }
    }
}
```

For for_each meta-argument(each iteration): List provides index as key and element as value; Set uses element as both key and value; Map/Object uses key-value pairs where key is the map key and value is the corresponding value.

Dynamic blocks can be used in resource blocks containing nested blocks, such as security groups or load balancer listeners and so on. However, they only apply to actual cloud provider-defined nested blocks not for lifecycle nested block.

<b><h3>Splat expression</h3></b>
Splat expression extract values from multiple resources one by one. They can be used in resource blocks and outputs. When using count or for_each, pass splat expression from dependent resources, as they return list(string) data types that can be iterated after typecasting to a set.

Splat expressions retrieve values from resources created by resource blocks using count or for_each meta-arguments. Otherwise, standard attribute reference syntax suffices for single resources.

```
syntax,

resource_type.logicalname.attributenameoftheresource

output "instance_dns" {
    value = aws_instance.web-instance.public_dns
}
```

Example: Splat expression is referred in the output,

```
#splat expression example
resource "aws_instance" "web_splat" {
    count = 2
    ami = "ami-0c398cb65a93047f2"
    associate_public_ip_address = true
    instance_type = var.environment != "Production" ? "t2.micro" : "t2.small"
    tags = {
        Name = "Web-app-instance-${count.index}"
    }
}

#output
output "instance_dns" {
    value = aws_instance.web_splat[*].public_dns
}
```

another example splat expression is referred in the resource block,

```
variable.tf
===========
variable "cidr_block" {
    type = list(string)
    default = ["10.0.0.0/16", "10.0.0.0/24", "10.0.1.0/24"]
}

variable "tags" {
    type = map(string)
    default = {
        Name = "test"
    }
}

variable "az" {
    type = list(string)
    default = ["us-east-1a", "us-east-1b"]
}


main.tf
=======
#VPC creation
resource "aws_vpc" "project_vpc" {
    cidr_block = var.cidr_block[0]
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = var.tags
}

#Subnet creation
resource "aws_subnet" "public_subnet" {
    count = 2
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = element(var.cidr_block, count.index+1)
    availability_zone = element(var.az, count.index)
    map_public_ip_on_launch = true
    tags = {
        Name = "demo-vpc-public-subnet-${count.index+1}"
    }
}

#instance creation
resource "aws_instance" "web_splat_example" {
    count = length(aws_subnet.public_subnet[*].id)
    ami = "ami-0c398cb65a93047f2"
    associate_public_ip_address = true
    subnet_id = element(aws_subnet.public_subnet[*].id, count.index)
    instance_type = var.environment != "Production" ? "t2.micro" : "t2.small"
    tags = {
        Name = "Web-app-instance-${count.index+1}"
    }
}

output.tf
=========
output "splat_instance_example_dns" {
    value = aws_instance.web_splat_example[*].public_dns
}

output "public-subnet-ids" {
    value = aws_subnet.public_subnet[*].id
}
```

<p align="center">
<b><i>Happy Learning </i></b>😊…..</p>