terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.23.0"
    }
  }
  required_version = "1.14.0"
}

provider "aws" {
    region = "us-east-1"
    profile = "personal-account"
}

#VPC creation
resource "aws_vpc" "terraform_practice_vpc" {
    region = "us-east-1"          # It will override if region mentioned in the provider block.
    cidr_block = "172.25.0.0/24"
    instance_tenancy = "default"  # default means shared tenancy
    enable_dns_support = true     # enable dns lookup things
    enable_dns_hostnames = true   # enable dns endpoint assignment
    tags = {
        Name = "Terraform_Practice_VPC"
        Environment = "Development"
        Created_by = "Terraform"
    }
}

#S3 bucket creation
resource "aws_s3_bucket" "data_bucket" {
    bucket = "terraform-practice-bucket-data-${aws_vpc.terraform_practice_vpc.id}"  #implicit dependency
    force_destroy = true  #It will destroy the bucket even the bucket has object while terraform destroy.
    tags = {
        Name = "Terraform-Practice-Data-Bucket"
        Environment = "Development"
        Created_by = "Terraform"
    }
}