output "web_instance_public_ip" {
    value = module.web_ec2.instance_public_ip
}

output "rds_endpoint" {
    value = module.rds.rds_endpoint
}