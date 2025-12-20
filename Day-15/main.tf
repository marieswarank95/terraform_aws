# #VPC creation in us-east-1 region
resource "aws_vpc" "app_vpc" {
    provider = aws.primary
    cidr_block = var.app_vpc_cidr
    instance_tenancy = var.instance_tenancy
    enable_dns_support = var.dns-support
    enable_dns_hostnames = var.dns-hostnames
    tags = merge(var.app_vpc_tags, {Name = "app-vpc"})
}

#subnets creation
resource "aws_subnet" "public-subnets" {
    provider = aws.primary
    count = length(local.availability_zones)
    cidr_block = cidrsubnet(var.app_vpc_cidr, 8, count.index)
    availability_zone = local.availability_zones[count.index]
    map_public_ip_on_launch = true
    vpc_id = aws_vpc.app_vpc.id
    tags = merge(var.app_vpc_tags, {Name = "app-vpc-public-subnet-${count.index}"})
}

resource "aws_subnet" "private-subnets" {
    provider = aws.primary
    count = length(local.availability_zones)
    cidr_block = cidrsubnet(var.app_vpc_cidr, 8, count.index + length(local.availability_zones))
    availability_zone = local.availability_zones[count.index]
    map_public_ip_on_launch = false
    vpc_id = aws_vpc.app_vpc.id
    tags = merge(var.app_vpc_tags, {Name = "app-vpc-private-subnet-${count.index}"})
}

#Internet Gateway Creation
resource "aws_internet_gateway" "app_igw" {
    provider = aws.primary
    vpc_id = aws_vpc.app_vpc.id
    tags = merge(var.app_vpc_tags, {Name = "app-vpc-IGW"})
}

#Route Table creation
resource "aws_route_table" "public-subnet-rt" {
    provider = aws.primary
    vpc_id = aws_vpc.app_vpc.id
    tags = merge(var.app_vpc_tags, {Name = "app-vpc-public-subnet-rt"})
}

resource "aws_route_table" "private-subnet-rt" {
    provider = aws.primary
    vpc_id = aws_vpc.app_vpc.id
    tags = merge(var.app_vpc_tags, {Name = "app-vpc-private-subnet-rt"})
}

resource "aws_route" "public-subnet-route-1" {
    provider = aws.primary
    route_table_id = aws_route_table.public-subnet-rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
}

resource "aws_route" "public-subnet-route-2" {
    provider = aws.primary
    route_table_id = aws_route_table.public-subnet-rt.id
    destination_cidr_block = var.db_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.app-db-peering.id
    depends_on = [aws_vpc_peering_connection_accepter.app-db-peering-accepter]
}

resource "aws_route" "private-subnet-route-1" {
    provider = aws.primary
    route_table_id = aws_route_table.private-subnet-rt.id
    destination_cidr_block = var.db_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.app-db-peering.id
    depends_on = [aws_vpc_peering_connection_accepter.app-db-peering-accepter]
}

#Associate RT with Subnets
resource "aws_route_table_association" "public-rt-link" {
    provider = aws.primary
    count = length(aws_subnet.public-subnets[*].id)
    route_table_id = aws_route_table.public-subnet-rt.id
    subnet_id = aws_subnet.public-subnets[count.index].id
}

resource "aws_route_table_association" "private-rt-link" {
    provider = aws.primary
    count = length(aws_subnet.private-subnets[*].id)
    route_table_id = aws_route_table.private-subnet-rt.id
    subnet_id = aws_subnet.private-subnets[count.index].id
}

# Secondary VPC 

# #VPC creation in us-west-2 region
resource "aws_vpc" "db_vpc" {
    provider = aws.secondary
    cidr_block = var.db_vpc_cidr
    instance_tenancy = var.instance_tenancy
    enable_dns_support = var.dns-support
    enable_dns_hostnames = var.dns-hostnames
    tags = merge(var.db_vpc_tags, {Name = "db-vpc"})
}

#subnets creation
resource "aws_subnet" "db-public-subnets" {
    provider = aws.secondary
    count = length(local.secondary_availability_zones)
    cidr_block = cidrsubnet(var.db_vpc_cidr, 8, count.index)
    availability_zone = local.secondary_availability_zones[count.index]
    map_public_ip_on_launch = true
    vpc_id = aws_vpc.db_vpc.id
    tags = merge(var.db_vpc_tags, {Name = "db-vpc-public-subnet-${count.index}"})
}

resource "aws_subnet" "db-private-subnets" {
    provider = aws.secondary
    count = length(local.secondary_availability_zones)
    cidr_block = cidrsubnet(var.db_vpc_cidr, 8, count.index + length(local.secondary_availability_zones))
    availability_zone = local.secondary_availability_zones[count.index]
    map_public_ip_on_launch = false
    vpc_id = aws_vpc.db_vpc.id
    tags = merge(var.db_vpc_tags, {Name = "db-vpc-private-subnet-${count.index}"})
}

#Internet Gateway Creation
resource "aws_internet_gateway" "db_igw" {
    provider = aws.secondary
    vpc_id = aws_vpc.db_vpc.id
    tags = merge(var.db_vpc_tags, {Name = "db-vpc-IGW"})
}

#Route Table creation
resource "aws_route_table" "db-public-subnet-rt" {
    provider = aws.secondary
    vpc_id = aws_vpc.db_vpc.id
    tags = merge(var.db_vpc_tags, {Name = "db-vpc-public-subnet-rt"})
}

resource "aws_route_table" "db-private-subnet-rt" {
    provider = aws.secondary
    vpc_id = aws_vpc.db_vpc.id
    tags = merge(var.db_vpc_tags, {Name = "db-vpc-private-subnet-rt"})
}

resource "aws_route" "db-public-subnet-route-1" {
    provider = aws.secondary
    route_table_id = aws_route_table.db-public-subnet-rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.db_igw.id
}

resource "aws_route" "db-public-subnet-route-2" {
    provider = aws.secondary
    route_table_id = aws_route_table.db-public-subnet-rt.id
    destination_cidr_block = var.app_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.app-db-peering.id
    depends_on = [aws_vpc_peering_connection_accepter.app-db-peering-accepter]
}

resource "aws_route" "db-private-subnet-route-1" {
    provider = aws.secondary
    route_table_id = aws_route_table.db-private-subnet-rt.id
    destination_cidr_block = var.app_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.app-db-peering.id
    depends_on = [aws_vpc_peering_connection_accepter.app-db-peering-accepter]
}

#Associate RT with Subnets
resource "aws_route_table_association" "db-public-rt-link" {
    provider = aws.secondary
    count = length(aws_subnet.db-public-subnets[*].id)
    route_table_id = aws_route_table.db-public-subnet-rt.id
    subnet_id = aws_subnet.db-public-subnets[count.index].id
}

resource "aws_route_table_association" "db-private-rt-link" {
    provider = aws.secondary
    count = length(aws_subnet.db-private-subnets[*].id)
    route_table_id = aws_route_table.db-private-subnet-rt.id
    subnet_id = aws_subnet.db-private-subnets[count.index].id
}

#VPC peering between app-vpc(us-east-1) and db-vpc(us-west-2)
resource "aws_vpc_peering_connection" "app-db-peering" {
    provider = aws.primary
    peer_vpc_id = aws_vpc.db_vpc.id
    peer_region = "us-west-2"
    vpc_id = aws_vpc.app_vpc.id
    tags = merge(var.app_vpc_tags, {Name = "app-db-vpc-peering"})
}

#VPC peering connection accepter
resource "aws_vpc_peering_connection_accepter" "app-db-peering-accepter" {
    provider = aws.secondary
    vpc_peering_connection_id = aws_vpc_peering_connection.app-db-peering.id
    auto_accept = true
    tags = merge(var.app_vpc_tags, {Name = "app-db-vpc-peering"})
}

#key pair creation
resource "aws_key_pair" "app-instance" {
    provider = aws.primary
    key_name = "app-instance"
    public_key = file("ec2_public_key.txt")
}

resource "aws_key_pair" "db-instance" {
    provider = aws.secondary
    key_name = "db-instance"
    public_key = file("ec2_public_key.txt")
}

#app instance security group creation
resource "aws_security_group" "app_instance_sg" {
    provider = aws.primary
    name = "app-instance-sg"
    description = "SG for app instance"
    vpc_id = aws_vpc.app_vpc.id

    dynamic ingress {
        for_each = {for rule in var.app-instance-sg-rules : rule.to_port => rule}
        content {
            from_port = ingress.value.from_port
            to_port = ingress.value.to_port
            protocol = ingress.value.protocol
            cidr_blocks = [ingress.value.cidr_block]
        }
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# db instance security group creation
resource "aws_security_group" "db_instance_sg" {
    provider = aws.secondary
    name = "db-instance-sg"
    description = "SG for db instance"
    vpc_id = aws_vpc.db_vpc.id

    dynamic ingress {
        for_each = {for rule in var.db-instance-sg-rules : rule.to_port => rule}
        content {
            from_port = ingress.value.from_port
            to_port = ingress.value.to_port
            protocol = ingress.value.protocol
            cidr_blocks = [ingress.value.cidr_block]
        }
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

#EC2 creation for app instance
resource "aws_instance" "app_instance" {
    provider = aws.primary
    ami = data.aws_ami.ubuntu_ami.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.public-subnets[0].id
    key_name = aws_key_pair.app-instance.key_name
    vpc_security_group_ids = [aws_security_group.app_instance_sg.id]
    tags = merge(var.app_vpc_tags, {Name = "app-instance"})
}

#EC2 creation for db instance
resource "aws_instance" "db_instance" {
    provider = aws.secondary
    ami = data.aws_ami.secondary_ubuntu_ami.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.db-public-subnets[0].id
    key_name = aws_key_pair.db-instance.key_name
    vpc_security_group_ids = [aws_security_group.db_instance_sg.id]
    tags = merge(var.app_vpc_tags, {Name = "app-instance"})
}