#random password generation for db password
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#Web EC2 SG creation
resource "aws_security_group" "web_sg" {
    name = "web-server-sg"
    description = "This sg used by web server."
    vpc_id = module.vpc.vpc_id
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "Web-server-sg"
    }
}

#RDS SG creation
resource "aws_security_group" "db_sg" {
    name = "db-sg"
    description = "This sg used by rds."
    vpc_id = module.vpc.vpc_id
    egress {
        from_port = 0
        to_port = 0
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "demo-terraform-rds-sg"
    }
}

#RDS SG rule creation
resource "aws_security_group_rule" "db_sg_rule" {
    security_group_id = aws_security_group.db_sg.id
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    source_security_group_id = aws_security_group.web_sg.id
}

#Key pair generation
resource "aws_key_pair" "web_kp" {
    key_name = "web_key"
    public_key = file("terraform.pub")
}

#==================================================================#

module "vpc" {
    source = "./modules/vpc"
    app_vpc_cidr = "172.20.0.0/16"
    instance_tenancy = "default"
    dns-support = true
    dns-hostnames = true
    app_vpc_tags = {Name = "Demo-terraform-VPC"}
}

module "rds" {
    source = "./modules/rds"
    rds_identifier = "demo-terraform-rds"
    engine_version = "8.0"
    rds_instance_type = "db.t3.micro"
    db_storage = 20
    db_name = "test_db"
    public_access = false
    port = 3306
    sg_ids = [aws_security_group.db_sg.id]
    skip_final_backup = true
    subnet_ids = module.vpc.private_subnet_ids
    subnet_group_name = "demo-terraform-db-subnets"
    username = "postgres"
    password = random_password.db_password.result
    backup_retention_days = 1
}

module "web_ec2" {
    source = "./modules/ec2"
    ami_id = data.aws_ami.web_ubuntu_ami.id
    instance_type = "t3.micro"
    subnet_id = lookup(module.vpc.public_subnet_ids_azs, "us-east-1a", "no-subnet")
    sg_id = [aws_security_group.web_sg.id]
    key_pair = aws_key_pair.web_kp.id
    db_host = module.rds.rds_endpoint
    db_username = module.rds.db_username
    db_password = random_password.db_password.result
    db_name = module.rds.db_name
    tags = {Name = "Web-server"}
}