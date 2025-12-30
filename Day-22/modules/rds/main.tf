#subnet group creation
resource "aws_db_subnet_group" "db_subnets" {
    name = var.subnet_group_name
    subnet_ids = var.subnet_ids
}

#RDS instance creation
resource "aws_db_instance" "db" {
    allocated_storage = var.db_storage
    apply_immediately = true
    backup_retention_period = var.backup_retention_days
    db_name = var.db_name
    db_subnet_group_name = aws_db_subnet_group.db_subnets.id
    engine = "mysql"
    engine_version = var.engine_version
    identifier = var.rds_identifier
    instance_class = var.rds_instance_type
    publicly_accessible = var.public_access
    port = var.port
    vpc_security_group_ids = var.sg_ids
    skip_final_snapshot = var.skip_final_backup
    username = var.username
    password = var.password
}