data "aws_availability_zones" "azs" {
    state = "available"
}

locals {
    filtered_azs = slice(data.aws_availability_zones.azs.names, 0, 3)
}