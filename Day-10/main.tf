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