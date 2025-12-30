variable "db_storage" {
    type = number
}

variable "backup_retention_days" {
    type = number
}

variable "db_name" {
    type = string
}

variable "engine_version" {
    type = string
}

variable "rds_identifier" {
    type = string
}

variable "rds_instance_type" {
    type = string
}

variable "public_access" {
    type = bool
}

variable "port" {
    type = number
}

variable "sg_ids" {
    type = set(string)
}

variable "skip_final_backup" {
    type = bool
}

variable "username" {
    type = string
}

variable "password" {
    type = string
    sensitive = true
}

variable "subnet_group_name" {
    type = string
}

variable "subnet_ids" {
    type = set(string)
}