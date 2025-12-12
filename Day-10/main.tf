#conditional expression example
resource "aws_instance" "web" {
    ami = "ami-0c398cb65a93047f2"
    associate_public_ip_address = true
    instance_type = var.environment != "Production" ? "t2.micro" : "t2.small"
    tags = local.tags 
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

resource "aws_vpc" "project_vpc" {
    cidr_block = var.cidr_block[0]
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = var.tags
}

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