variable "app_vpc_cidr" {
    type = string
}

variable "instance_tenancy" {
    type = string
}

variable "dns-support" {
    type = bool
}

variable "dns-hostnames" {
    type = bool
}

variable "app_vpc_tags" {
    type = map(string)
}