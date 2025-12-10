IAC (Infrastructure As Code):
It means creating and maintaining the infrastructure(Life Cycle of Infrastructure) by using code.

Benefits of IAC,
1. Speed up the environment setup.
2. Consistent in all environments setup (It avoids human error).

There are lot of tools for IAC.
1. Terraform
2. Pulumi
3. AWS cloud formation, AWS CDK (This can be used only in the AWS)
4. Azure Bicep (This can be used only in the Azure)

Terraform is supporting most of the cloud and popular one. We will see about this,

In Terraform, we are writing code in HCL(Hashicorp Configuration Language).

Terraform Workflow high level,
1. Installation of Terraform, use the below link to download the terraform package. In my case I am using windows so I picked windows option.

After download, install the application by using the exe app and set the terraform path in the system environment variable to execute the terraform commands from anywhere in the system.

2. Write the code to create any resource in the AWS cloud and then execute terraform init, this command will do some initialization activity like download the provider plugin and configure the backend. We will see about plugin and backend in the upcoming blog.

3. terraform plan command, it will show what are the resources will be created based on the configuration file but it is not showing any error.

4. terraform apply command, it will create the resources based on the configuration file. It will create the state file once the resources are created. It has actual environment details i.e. all details about the created resources.

5. terraform destroy command, it will delete all the resources that are created by the configuration file.

still there are lot of commands in the terraform, we will see one by one later. This is the high level terraform workflow. Every configuration file extension should be .tf then only terraform knows about it.