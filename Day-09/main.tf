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

#Ignore_changes example
resource aws_vpc "app_vpc" {
    cidr_block = var.cidr_block
    instance_tenancy = "default"
    enable_dns_support = var.dns_support
    enable_dns_hostnames = var.dns_hostnames
    tags = {
        Name = "test-vpc"
    }
}

resource aws_subnet "app-public-subnet" {
    vpc_id = aws_vpc.app_vpc.id
    availability_zone = "us-east-1a"
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = true
    tags = {
        Name = "app-public-subnet-1"
    }
}

# Security Group creation
resource "aws_security_group" "web_sg" {
    name = "web_app_instance_sg"
    description = "Security Group for web ec2 instance."
    vpc_id = aws_vpc.app_vpc.id
    tags = {
        Name = "web_app_instance_sg"
    }
    ingress {
        from_port = 443
        to_port = 443        
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

#key creation
resource "aws_key_pair" "web_instance" {
    key_name = "web_instance"
    public_key = "MENTION the PUBLIC KEY"
}

#IAM role creation
resource "aws_iam_role" "web_instance_role" {
    name = "web_ec2_role"
    description = "This role assume by EC2 to access some the resource in the AWS."
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  permissions_boundary = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  tags = {
    Name = "Web_EC2_Role"
  }
}

#instance profile role creation
resource "aws_iam_instance_profile" "web_instance_profile" {
    name = "web_instance_profile"
    role = aws_iam_role.web_instance_role.name
}

#Launch Template creation
resource "aws_launch_template" "web_lt" {
  name = "web_lt"
  iam_instance_profile {
    arn = aws_iam_instance_profile.web_instance_profile.arn
  }
  image_id = "ami-0ecb62995f68bb549"
  instance_type = "t2.micro"
  key_name = aws_key_pair.web_instance.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "terraform"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "terraform"
    }
  }
}

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

resource "aws_security_group" "api-sg" {
  name = "API-SG"
  description = "This SG for API instance."
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "API-Instance-SG"
  }
}

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