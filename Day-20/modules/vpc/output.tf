output "public_subnet_ids" {
    value = [for subnet in aws_subnet.public-subnets : subnet.id]
}

output "private_subnet_ids" {
    value = [for subnet in aws_subnet.private-subnets : subnet.id]
}

output "vpc_id" {
    value = aws_vpc.app_vpc.id
}