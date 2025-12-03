terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws" 
            version = "6.23.0"
        }
    }
    required_version = "1.14.0"
}

#Set(string) Constraint (allowed_region) example
provider "aws" {
    region = contains(var.allowed_region, var.region) ? var.region : "None"
    profile = "personal-account"
}