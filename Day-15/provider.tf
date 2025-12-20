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
    alias = "primary"
    region = "us-east-1"
    profile = "personal-account"
}

provider "aws" {
    alias = "secondary"
    region = "us-west-2"
    profile = "personal-account"
}