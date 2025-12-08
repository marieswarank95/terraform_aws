variable "environment" {
    type = string
    default = "Development"
}

variable "inbound_rules" {
    type = list(object({from_port = number, to_port = number, protocol = string, source = string}))
    default = [{from_port = 80, to_port = 80, protocol = "tcp", source = "0.0.0.0/0"}, {from_port = 443, to_port = 443, protocol = "tcp", source = "0.0.0.0/0"}]
}