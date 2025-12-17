#EC2 instance creation
resource "aws_instance" "web_instance" {
    count = length(data.aws_subnets.project_public_subnets.ids)
    ami = data.aws_ami.ubuntu_web_ami.id
    instance_type = var.instance_type
    subnet_id = element(data.aws_subnets.project_public_subnets.ids, count.index)
    associate_public_ip_address = true
    tags = {
        Name = "Web-Instance-${count.index}"
    }
}