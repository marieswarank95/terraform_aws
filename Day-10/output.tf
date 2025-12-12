output "instance_dns" {
    value = aws_instance.web_splat[*].public_dns
}

output "splat_instance_example_dns" {
    value = aws_instance.web_splat_example[*].public_dns
}

output "public-subnet-ids" {
    value = aws_subnet.public_subnet[*].id
}