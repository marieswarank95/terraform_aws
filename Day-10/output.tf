output "instance_dns" {
    value = aws_instance.web_splat[*].public_dns
}