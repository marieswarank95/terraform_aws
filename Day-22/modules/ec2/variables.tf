variable "ami_id" {
    type = string
}

variable "instance_type" {
    type = string
}

variable "subnet_id" {
    type = string
}

variable "sg_id" {
    type = set(string)
}

variable "key_pair" {
    type = string
}

variable "db_host" {
    type = string
}

variable "db_username" {
    type = string
}

variable "db_password" {
    type = string
}

variable "db_name" {
    type = string
}

variable "tags" {
    type = map(string)
}