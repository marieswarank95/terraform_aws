<!-- Center and Bold Title -->
<p align="center">
<b><h1>Terraform file structure and workflow</h1></b>
</p>

We will explore file structure and the Terraform workflow in a Terraform project.

Initially, you may write all Terraform configuration in a single file, which is fine when the number of infrastructure resources is small or the environment is simple. However, this becomes difficult to manage as the environment grows and the number of resources increases.

To avoid this, you can separate Terraform configuration files based on services.
For example, you can group all Terraform configurations related to networking resources into one file, and configurations for compute resources into another file. This makes the setup easier to manage.

The following is an example folder structure for a single-file Terraform configuration used for resource creation.

```
terraform-project/
├── backend.tf
├── main.tf
├── output.tf
├── provider.tf
├── terraform.tfvars
├── variables.tf
└── <project-name>-<env-name>.tfvars
```

If you want to split the main.tf file based on services, the file structure will look like the one shown below.

```
terraform-project/
├── backend.tf
├── provider.tf
├── variables.tf
├── output.tf
├── terraform.tfvars
├── <project-name>-<env-name>.tfvars
├── s3.tf
├── ec2.tf
├── networking.tf
└── rds.tf
```

<!-- Center and Bold Title -->
<p align="center">
<b><h1>Terraform execution flow</h1></b>
</p>
When you run terraform plan or terraform apply, Terraform loads all files with the .tf extension in alphabetical order, merges them into a single configuration in memory, and then builds a dependency graph. Based on this graph, Terraform creates resources either one by one or in parallel.

Please see the image graph.png then comes to here to read further.

I will explain the workflow based on this diagram. This diagram was generated using the following command, which requires the Graphviz tool.

```
terraform graph | dot -Tpng > graph.png
```

Based on this graph, Terraform identifies dependent resources, creates them first, and then creates the other resources. Independent resources are created in parallel.

The creation order for this scenario may be:
```
1) VPC
2) public_subnet_1 (Subnet)
3) public_subnet_2 (Subnet)
4) web_server_sg (SG)
5) web_server_sg_rule (SG-inbound-rule)
6) data_bucket_1 (S3)
7) web_instance (EC2)
8) web_instance_1 (EC2)
9) object_type_constraint (EC2)
```

* Resources 2, 3, and 4 may be created in parallel once the VPC resource is created.
* Resources 6, 7, 8, and 9 can also be created in parallel while create the VPC resource.