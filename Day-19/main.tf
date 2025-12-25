#local-exec terraform provisioner
resource "aws_s3_bucket" "test_bucket" {
    bucket = "terraform-practice-bucket-provisioner"

    provisioner "local-exec" {
        when = create  # vaild values [create, destroy] by default -> create
        command = "echo '${self.id} S3 bucket has been created.'"
    }
}

#remote-exec and file terraform provisioners
#EC2 SG creation
resource "aws_security_group" "web_sg" {
    name = "web-server-sg"
    description = "SG for Web server"
    # vpc_id  -> I am going to use default VPC
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

#Key Pair creation
resource "aws_key_pair" "web_key" {
    key_name = "web-key"
    public_key = file("terraform.pub")
}


resource "aws_instance" "web_instance" {
    ami = "ami-0ecb62995f68bb549"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.web_sg.name] #only for default VPC
    key_name = aws_key_pair.web_key.key_name

    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = file("terraform.pem")
        host = "${self.public_ip}"
    }

    provisioner "remote-exec" {
        inline = ["sudo apt-get update -y", "sudo apt-get install nginx -y"]
    }

    provisioner "file" {
        source = "${path.module}/terraform.html"
        destination = "/home/ubuntu/terraform.html"
    }

    provisioner "remote-exec" {
        script = "script.sh"
        #on_failure = fail or continue
    }
}