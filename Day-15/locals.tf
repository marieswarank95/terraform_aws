locals {
    availability_zones = [for az in data.aws_availability_zones.azs.names : az if can(regex("us-east-1[abc]$", az))]
    secondary_availability_zones = [for az in data.aws_availability_zones.secondary_azs.names : az if can(regex("us-west-2[abc]$", az))]
}