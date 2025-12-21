locals {
    filtered_azs = [for az in data.aws_availability_zones.azs.names : az if can(regex("us-east-1[abc]$", az))]
}