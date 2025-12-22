terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "6.23.0"
        }
        archive = {
            source = "hashicorp/archive"
            version = "2.7.1"
    }
    }
    required_version = "1.14.0"
}

provider "aws" {
    region = "us-east-1"
    profile = "personal-account"
}