<!-- Center and Bold Title -->
<p align="center">
<b><h1>Terraform Meta Arguments</h1></b>
</p>

We will explore Terraform meta arguments and their benefits.

<b><h3>What is a Terraform Meta Argument?</h3></b>
Meta arguments are provided by Terraform, not the actual cloud provider. They simplify writing Terraform configurations by avoiding repetitive code and some validation. They reduce the number of lines in Terraform configurations.

Meta arguments are differ from actual provider arguments (like resource properties required for specific resource creation). Instead, they handle operational activities like creating multiple resources with a single resource block and customizing default Terraform behaviors.

Meta arguments:
1. count
2. for_each
3. depends_on
4. lifecycle
5. provider

We will examine these meta arguments one by one.

<b><h3>count</h3></b>
The count meta argument helps create multiple resources using the same resource block — no need to write multiple resource blocks.

When used in a resource block, Terraform identifies each created resource by an index. However, it may cause unexpected resource replacements, so use this meta argument with awareness.

Example Scenario
You need to create three S3 buckets. Use the count meta argument in the resource block:

```
variable "bucket_names" {
    type = list(string)
    default = ["bucket-1", "bucket-2", "bucket-3"]
}

resource "aws_s3_bucket" "buckets" {
    count = length(var.bucket_names)
    bucket = var.bucket_names[count.index]
    tags = {
        Name = var.bucket_names[count.index]
    }
}
```

It creates three S3 buckets with names: bucket-1, bucket-2, bucket-3.

These buckets are identified by index:

```
aws_s3_bucket.buckets[0] -> bucket-1
aws_s3_bucket.buckets[1] -> bucket-2
aws_s3_bucket.buckets[2] -> bucket-3
```

Problem Scenario
Suppose you remove bucket-2 from the bucket_names variable.

```
variable "bucket_names" {
    type = list(string)
    default = ["bucket-1", "bucket-3"]
}
```

When you run terraform plan, Terraform compares:

Current state,
```
aws_s3_bucket.buckets[0] -> bucket-1
aws_s3_bucket.buckets[1] -> bucket-2
aws_s3_bucket.buckets[2] -> bucket-3
```

New configuration,
```
aws_s3_bucket.buckets[0] -> bucket-1
aws_s3_bucket.buckets[1] -> bucket-3
```

Unexpected Behavior, Terraform detects:

Index 1: State has bucket-2, config has bucket-3 → Deletes bucket-2, creates bucket-3 (unexpected creation!)

Index 2: State has bucket-3, no index 2 in config → Deletes bucket-3

Expected: Delete only bucket-2, keep bucket-1 and bucket-3.
Actual: Unwanted replacements occur.

count works well for identical resources but causes unexpected replacements when list order changes. Use with awareness of its pros and cons.

<b><h3>for_each</h3></b>
It also helps create multiple resources with the same resource block, but it identifies each resource by using a key instead of an index. The key, in this example, is the bucket name (Terraform identifies the resource by the element used as the key in the for_each meta argument).

```
variable "bucket_names" {
    type = list(string)
    default = ["bucket-1", "bucket-2", "bucket-3"]
}

resource "aws_s3_bucket" "buckets" {
    for_each = toset(var.bucket_names)  # It expects set(string) or map
    bucket = each.value
    tags = {
        Name = each.value
    }
}
```

It creates three S3 buckets. The resources are identified as:

```
aws_s3_bucket.buckets["bucket-1"] -> bucket-1
aws_s3_bucket.buckets["bucket-2"] -> bucket-2
aws_s3_bucket.buckets["bucket-3"] -> bucket-3
```

Suppose bucket-2 is removed from the bucket_names variable. After running terraform plan, Terraform behaves as follows:

```
aws_s3_bucket.buckets["bucket-1"] -> bucket-1
```

The next element is bucket-3, and there is already a resource in the state with this key:

```
aws_s3_bucket.buckets["bucket-3"]
```

Since there is no resource in the configuration for the key “bucket-2”, Terraform decides to destroy the bucket-2 resource.

Because resources are matched by key instead of index, this avoids unexpected replacements.

<b><h3>depends_on</h3></b>
By default, Terraform detects all implicit dependencies and creates resources in the correct order.

However, in some cases, Terraform cannot detect dependencies. For example:

Scenario: An S3 bucket must be created before an EC2 instance, even though the instance resource block doesn’t reference the S3 bucket.

The EC2 instance deploys an application via a provisioner. This application requires the S3 bucket to exist before it starts, otherwise it will throw an error.

Solution: Use the depends_on meta argument explicitly:

```
resource "aws_s3_bucket" "data_bucket" {
    bucket = "terraform-practice-bucket-data"
    force_destroy = true
    tags = {
        Name = "Terraform-Practice-Data-Bucket"
        Environment = "Development"
        Created_by = "Terraform"
    }
}

resource aws_instance "web_instance" {
    ami = "ami-0c398cb65a93047f2"
    instance_type = var.instance_type
    tags = {
        Name = "Web_Instance"
    }

    depends_on = [aws_s3_bucket.data_bucket]
}
```

This configuration will create S3 bucket first and then EC2 instance.