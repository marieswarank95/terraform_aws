output "primary_ubuntu_ami_id" {
    value = data.aws_ami.ubuntu_ami.id
}

output "secondary_ubuntu_ami_id" {
    value = data.aws_ami.secondary_ubuntu_ami.id
}

output "primary_azs" {
    value = data.aws_availability_zones.azs.names
}

output "primary_filtered_azs" {
    value = local.availability_zones
}

output "secondary_azs" {
    value = data.aws_availability_zones.secondary_azs.names
}

output "secondary_filtered_azs" {
    value = local.secondary_availability_zones
}

output "primary_vpc_resources" {
    value = {
        vpc_id = aws_vpc.app_vpc.id
        public_subnet_id = aws_subnet.public-subnets[*].id
        private_subnet_id = aws_subnet.private-subnets[*].id
    }
}

output "secondary_vpc_resources" {
    value = {
        vpc_id = aws_vpc.db_vpc.id
        public_subnet_id = aws_subnet.db-public-subnets[*].id
        private_subnet_id = aws_subnet.db-private-subnets[*].id
    }
}

output "vpc_peering_status" {
    value = aws_vpc_peering_connection.app-db-peering.accept_status
}