<!-- Center and Bold Title -->
<p align="center">
<b><h1>Terraform Provider</h1></b>
</p>

<!-- Bold Subtitle -->
<p align="center">
<b>What is provider in terraform and role of this?</b>
</p>

<p>
Terraform supports most of the cloud provider. In this case if we are going to provision the resources in AWS, then AWS will be the provider. For this we need to use terraform and provider block in the configuration.

The Terraform block specifies the providers to use, including the provider package source and version in the required_providers block, along with the required Terraform version.

The Provider block needs to specify the configurations required for the provider to function.
</p>

<b><h3>Version constraints</h3></b>
1] = means it expects the exact version.​

2] != means it excludes the particular version.​

3] >= means it expects the specified version or newer versions.​

4] <= means it expects the specified version or older versions.​

5] ~> operator expects the specified version or the latest minor/patch versions but not the next major version.

examples,

~> 1.2.0 allows 1.2.0 and newer patch versions (≥1.2.0, <1.3.0)

~> 1.2 allows 1.2.0 and newer patch versions (≥1.2.0, <1.3.0)

This version constraint locks the versions of both the provider and Terraform. You may have doubts about the Terraform version constraint since Terraform is already installed, but it helps when working in a team. The version constraint ensures all team members use the same Terraform version to avoid issues. It enforce to satisfy the terraform version constraint, otherwise it will throw error while executing the commands.

<b><h3>🚀Provider roles🚀</h3></b>
Once the Terraform and provider blocks are defined, execute the terraform init command. It initializes the backend, downloads, and installs the specified provider plugins. The provider plugins translate Terraform code into API calls that the actual provider services understand, which then process the requests.

In the provider block, we can specify the region, credentials, and other settings. The provider uses the region to create infrastructure based on the configuration and verifies credentials to determine whether the necessary permissions exist for particular actions.

Once executed the terraform init command, it will create .terraform folder and .terraform.lock.hcl file.

Terraform has locked the provider version(mentioned version while execute the terraform init) in the terraform.lock.hcl file, so it will helps to maintain the same version of provider across all team members.