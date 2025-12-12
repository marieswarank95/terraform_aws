terraform {
    backend "s3" {
        bucket = "" # mention the bucket name that is going to use manage the terraform state.
        key = "dev/terraform-practice-state"
        profile = "personal-account"
        use_lockfile = true  # This argument helps state locking to avoid file corruption. 
        region = "us-east-1" 
    }
}