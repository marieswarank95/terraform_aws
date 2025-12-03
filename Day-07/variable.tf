variable "region" {
    type = string
    description = "region name"
    default = "us-east-1"
}

variable "environment" {
    type = string
    description = "name of the environment"
    default = "qa"
}

variable "instance_count" {
    type = number
    description = "number of ec2 instances"
    default = 2
}

variable "instance_name" {
    type = list(string)
    description = "name of the instance"
    default = ["web-server-1", "web-server-2"]
}

variable "monitoring_enabled" {
    type = bool
    default = true
}

variable "associate_public_ip" {
    type = bool
    default = true
}

variable "cidr_block" {
    type = list(string)
    default = ["10.0.0.0/16", "10.0.0.0/24", "10.0.1.0/24"]
}

variable "allowed_vm_types" {
    type = list(string)
    default = ["t2.micro", "t2.small", "t3.micro", "t3.small"]
}

variable "instance_type" {
    type = string
    default = "t3.small"
}

variable "allowed_region" {
    type = set(string)
    default = ["us-east-1", "us-west-2", "eu-west-1"]
}

variable "tags" {
    type = map(string)
    default = {Name="demo-vpc", Environment="QA", Created_by="Terraform"}
}

variable "ingress_values" {
    type = tuple([number, string, number])
    default = [443, "tcp", 443]
}

variable "config" {
    type = object({region=string, monitoring=bool, instance_count=number})
    default = {region="us-east-1", monitoring=true, instance_count=1}
}