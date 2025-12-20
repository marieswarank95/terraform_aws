variable "instance_type" {
    type = string
    default = "t3.micro"
}

variable "assign_public_ip" {
    type = bool
    default = true
}

variable "app_vpc_tags" {
    type = map(string)
    default = {
        Project = "Web-application"
        Environment = "Development"
    }
}

variable "app_vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "dns-support" {
    type = bool
    default = true
}

variable "dns-hostnames" {
    type = bool
    default = true
}

variable "instance_tenancy" {
    type = string
    default = "default"
}

variable "db_vpc_tags" {
    type = map(string)
    default = {
        Project = "Web-application"
        Environment = "Development"
    }
}

variable "db_vpc_cidr" {
    type = string
    default = "10.1.0.0/16"
}

variable "app-instance-sg-rules" {
    type = list(object({from_port = number, to_port = number, protocol = string, cidr_block = string}))
    default = [{from_port = -1, to_port = -1, protocol = "ICMP", cidr_block = "10.1.0.0/16"}, {from_port = 22, to_port = 22, protocol = "TCP", cidr_block = "0.0.0.0/0"}]
}

variable "db-instance-sg-rules" {
    type = list(object({from_port = number, to_port = number, protocol = string, cidr_block = string}))
    default = [{from_port = -1, to_port = -1, protocol = "ICMP", cidr_block = "10.0.0.0/16"}, {from_port = 22, to_port = 22, protocol = "TCP", cidr_block = "0.0.0.0/0"}]
}