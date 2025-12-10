<!-- Center and Bold Title -->
<p align="center">
<b><h1>Terraform Variables</h1></b>
</p>

We will explore the Terraform Variables and key concepts.

1] Input variable

2] Local variable

3] output variable

<b><h3>Input variable</h3></b>

This helps avoid hardcoding values in Terraform configurations by allowing you to pass values dynamically. If the same value were hardcoded in multiple places, any required change would mean updating it everywhere it’s configured, which is error-prone and time-consuming. By using variables or dynamic inputs, you change the value in one place, and it applies throughout the configuration.

<i>We can pass values in multiple ways, but Terraform has a specific precedence order. Let’s review the priority:</i>

1] CLI arguments (-var, -var-file flags) have the highest priority.
If you use both -var and -var-file together on the CLI, the right-most one takes precedence for conflicting variables in the order they appear.

```
terraform plan -var=environment=sit -var=project=desktop-app -var-file=config.tfvars
```

2] *.auto.tfvars files are auto-loaded only if no CLI -var or -var-file flags are used. These automatically assign values to variables.

3] terraform.tfvars is considered next if neither CLI flags nor auto.tfvars are used.

```
terraform.tfvars
project = "mobile-application"
vpc_cidr = "172.25.0.0/24"
environment = "UAT"
```

4] Environment variables prefixed with TF_VAR_ come next in precedence.

```
export TF_VAR_<variable_name>=value
export TF_VAR_environment="production"
```

5] Default values in variable declarations are used if none of the above provide a value.

```
variable "environment" {
    default = "Demo"
}

variable "project" {
    default = "web-application"
}

variable "region_name" {
    default = "us-east-1"
}

variable "vpc_cidr" {
    type = "string"
    description = "VPC cidr range"
    default = "10.0.0.0/24"
}
```

If a variable is declared and referenced but no value is provided through any of these methods, Terraform prompts for a value interactively during terraform plan and terraform apply.

If we use a .tfvars file with a different name rather than terraform.tfvars or something.auto.tfvars, we need to pass the file explicitly using the -var-file flag if we want Terraform to use the values present in that file.

```
terraform apply -var-file="something.tfvars"
```

<b><h3>Local variable</h3></b>

In input variables, the value should be a literal, not an expression. However, expressions can be used within locals. This approach helps avoid repeating expressions everywhere they are needed by instead referencing something like local.key, for example local.tags. In this variable we can use expression.

```
locals {
    tags = "${var.environment}-${var.project}"
}
```

<b><h3>Output variable</h3></b>

It helps to view details of created resources in the display once terraform apply is executed. However, it does not show all details about the resource, only what is specified in the output block.

You can also view the created resource details by running the terraform output command.

```
output block syntax,

output "output_variable_name" {
    value=resource_type.logical_name.attribute_name
}
```

example,
```
output "bucket_arn" {
    value=aws_s3_bucket.web_bucket.arn
}


In this aws_s3_bucket  -> resource type
        web_bucket     -> logical name of the resource block
        arn            -> attribute name
```

terraform output

```
$ terraform output
bucket_arn = "arn:aws:s3:::terrafrom-bucket-web"
```

Each resource returns its own attributes, which we can refer to in an output block. This allows the output to return specific details about the resource. Outputs are also used to export values from one module to another.

This means you define outputs to expose the important attributes you want to share or display, facilitating data flow between modules or for user visibility.