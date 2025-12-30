# #VPC creation in us-east-1 region
resource "aws_vpc" "app_vpc" {
    cidr_block = var.app_vpc_cidr
    instance_tenancy = var.instance_tenancy
    enable_dns_support = var.dns-support
    enable_dns_hostnames = var.dns-hostnames
    tags = merge(var.app_vpc_tags, {Name = "app-vpc"})
}

#subnets creation
resource "aws_subnet" "public-subnets" {
    for_each = {for index, az in local.filtered_azs : az => index}
    cidr_block = cidrsubnet(var.app_vpc_cidr, 8, each.value)
    availability_zone = each.key
    map_public_ip_on_launch = true
    vpc_id = aws_vpc.app_vpc.id
    tags = merge(var.app_vpc_tags, {Name = "app-vpc-public-subnet-${each.value + 1}"})
}

resource "aws_subnet" "private-subnets" {
    for_each = {for index, az in local.filtered_azs : az => index}
    cidr_block = cidrsubnet(var.app_vpc_cidr, 8, each.value + length(local.filtered_azs))
    availability_zone = each.key
    map_public_ip_on_launch = false
    vpc_id = aws_vpc.app_vpc.id
    tags = merge(var.app_vpc_tags, {Name = "app-vpc-private-subnet-${each.value + 1}"})
}

#Internet Gateway Creation
resource "aws_internet_gateway" "app_igw" {
    vpc_id = aws_vpc.app_vpc.id
    tags = merge(var.app_vpc_tags, {Name = "app-vpc-IGW"})
}

#EIP creation
resource "aws_eip" "ng_eip" {
    domain = "vpc"
    tags = {
        Name = "NAT Gateway EIP"
    }
}

#NAT Gateway creation
resource "aws_nat_gateway" "ng" {
    allocation_id = aws_eip.ng_eip.id
    subnet_id = aws_subnet.public-subnets["us-east-1a"].id
}

#Route Table creation
resource "aws_route_table" "public-subnet-rt" {
    vpc_id = aws_vpc.app_vpc.id
    tags = merge(var.app_vpc_tags, {Name = "app-vpc-public-subnet-rt"})
}

resource "aws_route_table" "private-subnet-rt" {
    vpc_id = aws_vpc.app_vpc.id
    tags = merge(var.app_vpc_tags, {Name = "app-vpc-private-subnet-rt"})
}

resource "aws_route" "public-subnet-route-1" {
    route_table_id = aws_route_table.public-subnet-rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
}

resource "aws_route" "private-subnet-route-1" {
    route_table_id = aws_route_table.private-subnet-rt.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ng.id
}

#Associate RT with Subnets
resource "aws_route_table_association" "public-rt-link" {
    for_each = {for subnet in aws_subnet.public-subnets : subnet.availability_zone => subnet.id}
    route_table_id = aws_route_table.public-subnet-rt.id
    subnet_id = each.value
}

resource "aws_route_table_association" "private-rt-link" {
    for_each = {for subnet in aws_subnet.private-subnets : subnet.availability_zone => subnet.id}
    route_table_id = aws_route_table.private-subnet-rt.id
    subnet_id = each.value
}