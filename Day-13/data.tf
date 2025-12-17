#data source block for fetching ami details.
data "aws_ami" "ubuntu_web_ami" {
    owners = ["amazon"]
    most_recent = true
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }
    filter {
        name = "state"
        values = ["available"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

#fetching VPC details
data "aws_vpc" "project_vpc" {
    state = "available"
    filter {
        name = "tag:Name"
        values = ["Demo-web-application"]
    }
}

#fetching public subnets details from the VPC details
data "aws_subnets" "project_public_subnets" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.project_vpc.id]
    }
    filter {
        name = "tag:Name"
        values = ["*public*"]
    }
}

#fetching private subnets details from the VPC details
data "aws_subnets" "project_private_subnets" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.project_vpc.id]
    }
    filter {
        name = "tag:Name"
        values = ["*private*"]
    }
}