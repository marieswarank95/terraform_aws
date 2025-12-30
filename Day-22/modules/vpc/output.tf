output "public_subnet_ids" {
    value = [for subnet in aws_subnet.public-subnets : subnet.id]
}

output "public_subnet_ids_azs" {
    value = {for subnet in aws_subnet.public-subnets : subnet.availability_zone => subnet.id}
}

output "private_subnet_ids" {
    value = [for subnet in aws_subnet.private-subnets : subnet.id]
}

output "private_subnet_ids_azs" {
    value = {for subnet in aws_subnet.private-subnets : subnet.availability_zone => subnet.id}
}

output "vpc_id" {
    value = aws_vpc.app_vpc.id
}

output "ng_eip" {
    value = aws_eip.ng_eip.public_ip
}