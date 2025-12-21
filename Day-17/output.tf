output "vpc_id" {
    value = aws_vpc.app_vpc.id
}

output "public_subnet_ids" {
    value = [for subnet in aws_subnet.public-subnets : subnet.id]
}

output "private_subnet_ids" {
    value = [for subnet in aws_subnet.private-subnets : subnet.id]
}

# output "pub_subnet_ids" {
#     value = local.public_subnet_ids
# }

output "eb_app_name" {
    value = aws_elastic_beanstalk_application.eb_web_app.name
}

output "eb_app_version_name_1" {
    value = aws_elastic_beanstalk_application_version.blue_env_version.name
}

output "eb_app_version_name_2" {
    value = aws_elastic_beanstalk_application_version.green_env_version.name
}

output "eb_environment_url" {
    value = aws_elastic_beanstalk_environment.blue_environment.endpoint_url
}