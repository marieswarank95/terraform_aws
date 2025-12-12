variable "environment" {
    type = string
    default = "Development"
}

variable "inbound_rules" {
    type = list(object({from_port = number, to_port = number, protocol = string, source = string}))
    default = [{from_port = 80, to_port = 80, protocol = "tcp", source = "0.0.0.0/0"}, {from_port = 443, to_port = 443, protocol = "tcp", source = "0.0.0.0/0"}]
}

variable "cidr_block" {
    type = list(string)
    default = ["10.0.0.0/16", "10.0.0.0/24", "10.0.1.0/24"]
}

variable "tags" {
    type = map(string)
    default = {
        Name = "test"
    }
}

variable "az" {
    type = list(string)
    default = ["us-east-1a", "us-east-1b"]
}