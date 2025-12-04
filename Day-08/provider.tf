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
    region = var.region
    profile = "personal-account"
}