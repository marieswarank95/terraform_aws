<!-- Center and Bold Title -->
<p align="center">
<b><h1>Terraform State Management</h1></b>
</p>

we will explore the Terraform state file and key concepts.

🚀 Terraform state file importance.

🚀 Local backend vs Remote backend.

🚀 State locking purpose.

<!-- Center and Bold Title -->
<p align="center">
<b><h3>Terraform state file importance</h3></b>
</p>

The Terraform state file is created during terraform plan but remains empty until terraform apply populates it with created resources.

Terraform uses this state file to track actual infrastructure and compare it against the current configuration to determine required actions (create, update, delete).

Empty state + new resources → Creates resources and updates state

Updated config → Compares with state → Updates/recreates resources and updates state

Removed config → Compares with state → Destroys resources from infrastructure and updates state

The above mentioned things will do while execute the terraform plan and terraform apply command.

terraform plan determines actions; terraform apply executes them.

<!-- Center and Bold Title -->
<p align="center">
<b><h3>Local backend vs Remote backend</h3></b>
</p>
Once all configuration files are created, execute the terraform init command. It initializes the backend and downloads and installs the specified provider plugins. Without a backend block, it defaults to the local backend, storing the state file on the local machine where the configuration files and Terraform commands are executed.

If an S3 backend is specified as remote backend, it stores the state file in the S3 bucket defined in the backend block. This backend configuration enables team collaboration and avoids issues caused by local machine failures.

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.23.0"
    }
  }
  
  backend "s3" {
  bucket = "terraform-practice-state-management"
  region = "us-east-1"
  key = "dev/terraform.tfstate"
  use_lockfile = true
  profile = "personal-account"
  }

  required_version = "1.14.0"
}

State locking purpose:
State locking prevents concurrent modifications when multiple team members run Terraform simultaneously, avoiding state file corruption. Without locking (enabled by most remote backends), parallel operations can corrupt state, making infrastructure unmanageable despite existing cloud resources.

State locking feature is now available in S3 bucket itself, no need Dynamo DB table.