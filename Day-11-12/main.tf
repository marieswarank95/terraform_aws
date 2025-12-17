#variables
variable "az" {
    type = list(string)
    default = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
    type = string
    default = "192.168.0.0/24"
}

#VPC creation
resource "aws_vpc" "test_vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "Test-VPC"
    }
}

#Subnet creation [Using function length, cidrsubnet and combined with count meta argument]
resource "aws_subnet" "public-subnets" {
    count = length(var.az)
    vpc_id = aws_vpc.test_vpc.id
    availability_zone = var.az[count.index]
    cidr_block = cidrsubnet(var.vpc_cidr, length(var.az)-1, count.index)
    tags = {
        Name = "public-subnet-${count.index+1}"
    }
}