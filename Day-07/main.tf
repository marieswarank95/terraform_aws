#String Constraint (environment, region) example
resource "aws_s3_bucket" "data_bucket_1" {
    bucket = "${var.environment}-terraform-practice-bucket-data"
    tags = {
        Environment = var.environment
    }
}

#Number and Bool type Constraint (instance_count) example
resource "aws_instance" "web_instance" {
    count = var.instance_count
    ami = "ami-0ecb62995f68bb549"
    instance_type = "t3.micro"
    monitoring = var.monitoring_enabled
    associate_public_ip_address = var.associate_public_ip
    tags = {
        Name = var.instance_name[count.index]
        Environment = var.environment
    }
}

#List(string) Constraint (allowed_vm_types) example
resource "aws_instance" "web_instance_1" {
    #count = contains(var.allowed_vm_types, var.instance_type) ? var.instance_count : 0  # contains -> function -> syntax contains(list or set, actual given value)
    ami = "ami-0ecb62995f68bb549"
    instance_type = var.instance_type
    monitoring = var.monitoring_enabled
    associate_public_ip_address = var.associate_public_ip
    tags = {
        Name = "web_server"
        Environment = var.environment
    }

    lifecycle {
        precondition {
            condition = contains(var.allowed_vm_types, var.instance_type)
            error_message = "The instance type should be t2.micro, t2.small, t3.micro, t3.small"
        }
    }
}

#List(string) Constraint (cidr_block) and Map(string) Constraint (tags) example
resource "aws_vpc" "project_vpc" {
    cidr_block = var.cidr_block[0]
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = var.tags
}

resource "aws_subnet" "public_subnet_1" {
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = var.cidr_block[1]
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "demo-vpc-public-subnet-1"
    }
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id = aws_vpc.project_vpc.id
    cidr_block = var.cidr_block[2]
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
    tags = {
        Name = "demo-vpc-public-subnet-2"
    }
}

resource "aws_security_group" "web_server_sg" {
    name = "Web_server_SG"
    vpc_id = aws_vpc.project_vpc.id
    tags = {
        Name = "Web_Server_SG"
    }
}

#Tuple Constraint (ingress_values) example
resource "aws_security_group_rule" "web_server_sg_rule" {
    from_port = var.ingress_values[0]
    to_port = var.ingress_values[2]
    protocol = var.ingress_values[1]
    security_group_id = aws_security_group.web_server_sg.id
    type = "ingress"
    cidr_blocks = ["0.0.0.0/0"]
}

#Object Constraint (config) example
resource aws_instance "object_type_constraint" {
    count = var.config["instance_count"]
    region = var.config["region"]
    ami = "ami-0ecb62995f68bb549"
    instance_type = "t3.micro"
    monitoring = var.config["monitoring"]
    associate_public_ip_address = true
    disable_api_termination = false
    tags = {
        Name = "object-vm"
    }
    
}