output "ubuntu_web_ami_id" {
    value = data.aws_ami.ubuntu_web_ami.id
}

output "vpc_id" {
    value = data.aws_vpc.project_vpc.id
}

output "public_subnets_ids" {
    value = data.aws_subnets.project_public_subnets.ids
}

output "private_subnet_ids" {
    value = data.aws_subnets.project_private_subnets.ids
}

output "instance_ids" {
    value = aws_instance.web_instance[*].id
}