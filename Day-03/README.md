<!-- Center and Bold Title -->
<p align="center">
<b><h1>Terraform resource block</h1></b>
</p>


Resource block helps to create the resources. This block is defined by resource keyword. Please find the syntax below,

```
resource resource_type_name logical_name {
    supported argument 1
    supported argument 2
}
```

For arguments, refer to the Terraform documentation. Each resource has its own arguments. Here, I provide a sample S3 bucket creation resource block.

```
resource "aws_s3_bucket" "web_bucket" {
  bucket = "terrafrom-practice-bucket-web"
  tags = {
    Name = "terraform-practice-bucket-web"
    Environment = "Development"
  }
}
```

<b>aws_s3_bucket</b> -> resource type (The provider name serves as the prefix in the resource type.)

<b>web_bucket</b> -> The logical name for this resource block will be used to reference it in other resource blocks when required.

<b>bucket, tags</b> -> Supported arguments.

There are lot of arguments for every resource, but we can use the required one and also must be use the mandatory argument.

After this, execute the terraform plan command. It shows which resources will be created, updated, or deleted based on the Terraform configuration files and Terraform state file. We will explore the Terraform state file in depth in the next blog.

```
terraform plan
```

Once done, execute the terraform apply command to provision the resources. It creates the resources based on the configuration and also creates a state file(If this is the first terraform apply execution), managing it locally because no remote backend is defined, so it defaults to the local backend.

```
terraform apply
```

The terraform destroy command deletes all resources managed by Terraform that are tracked in the state file. Once all resources are deleted, it also removes them from the state file.

```
terraform destroy
```