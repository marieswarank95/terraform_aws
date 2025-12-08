variable "allowed_vm_types" {
    type = list(string)
    default = ["t2.micro", "t2.small", "t3.micro", "t3.small"]
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "cidr_block" {
    type = string
    default = "10.0.0.0/16"
}

variable "dns_support" {
    type = bool
    default =  true
}

variable "dns_hostnames" {
    type = bool
    default = true
}
