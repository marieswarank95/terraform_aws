variable "bucket_name" {
    type = string
    default = "terraform-practice-bucket-eb-code"
}

variable "file_upload" {
    type = list(string)
    default = ["app_v1", "app_v2"]
}

variable "app_vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "instance_tenancy" {
    type = string
    default = "default"
}

variable "dns-support" {
    type = bool
    default = true 
}

variable "dns-hostnames" {
    type = bool
    default = true
}

variable "app_vpc_tags" {
    type = map(string)
    default = {
        Name = "app-vpc"
        Environment = "Development"
    }
}

variable "ec2_policies_arn" {
    type = set(string)
    default = ["arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier", "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier", "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"]
}