resource "aws_instance" "web_instance" {
    ami = var.ami_id
    instance_type = var.instance_type
    key_name = var.key_pair
    subnet_id = var.subnet_id
    vpc_security_group_ids = var.sg_id
    user_data = templatefile("${path.module}/template/user_data.sh", {db_host = var.db_host, db_username = var.db_username, db_password = var.db_password, db_name = var.db_name})
    tags = var.tags
}