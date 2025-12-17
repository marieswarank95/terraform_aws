<!-- Center and Bold Title -->
<p align="center">
<b><h1>Terraform Data Sources:</h1></b>
</p>

We can relate this to simple real-world examples. If you want to check which subnets exist and get their subnet IDs, you first need to know which VPC to look in. This is typically done manually by logging into the AWS console, navigating to the VPC page, noting the VPC ID, then going to the Subnets page, applying a VPC ID filter, and viewing all subnets and their IDs in that VPC.

Terraform data sources can automate this, but you still need prior details like the VPC ID or VPC tag name to retrieve subnets or other resources information under that VPC. This mentioned filter for this scenario only. Based on the resource type the filter and argument will be vary.

Here’s an example to understand this and its purpose. In this example, I have already created a VPC and subnets within it. I want to launch instances in this VPC, but the VPC and subnets are not managed by Terraform. <i>How do you achieve this?</i> <b>In this scenario, Terraform data sources come into play and serve that role. They not only retrieve resource details dynamically but also help provision resources in existing infrastructure not managed by Terraform.</b>

```
data source block syntax,

data "resource_type" "logical_name_of_this_block" {
          #supported arguments
          #filter block
}

#fetching VPC details
data "aws_vpc" "project_vpc" {
    state = "available"
    filter {
        name = "tag:Name"
        values = ["Demo-web-application"]
    }
}
```

In the resource block, refer to the value fetched by the data source using the syntax below:

<b>data.aws_vpc.project_vpc.id</b>

<b>data</b> -> Keyword for the data source block.

<b>aws_vpc</b> -> Resource type

<b>project_vpc</b> -> Logical name of this block

<b>id</b> -> Attribute

It will return specific attributes; pick the one you need to reference in the resource block.

<b><h3>Data Source:</h3></b>
1. It helps fetch details of existing resources.
2. It helps provision resources in existing infrastructure not managed by Terraform.
3. It does not create, update, or terminate resources. For that, use resource blocks.