data "aws_ami" "ubuntu_ami" {
    provider = aws.primary
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name = "state"
        values = ["available"]
    }
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }
}

data "aws_ami" "secondary_ubuntu_ami" {
    provider = aws.secondary
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    filter {
        name = "state"
        values = ["available"]
    }
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }
}

data "aws_availability_zones" "azs"{
    provider = aws.primary
    state = "available"
}

data "aws_availability_zones" "secondary_azs"{
    provider = aws.secondary
    state = "available"
}