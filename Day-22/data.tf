data "aws_ami" "web_ubuntu_ami" {
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