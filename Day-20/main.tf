module "vpc" {
    source = "./modules/vpc"
    app_vpc_cidr = "192.168.0.0/16"
    instance_tenancy = "default"
    dns-support = true
    dns-hostnames = true
    app_vpc_tags = {
        Name = "terraform-module-practice-vpc"
    }
}

module "eks" {
    source = "./modules/eks"
    eks_cluster_name = "terraform-practice-module"
    vpc_id = module.vpc.vpc_id
    kubernetes_version = "1.33"
    eks_authentication_mode = "API"
    eks_scaling_tier = "standard"
    eks_upgrade_policy = "STANDARD"
    eks_logging = ["api"]
    eks_deletion_protection = false
    eks_api_private_access = true
    eks_api_public_access = true
    eks_access_cidrs = ["0.0.0.0/0"]
    eks_subnet_ids = module.vpc.public_subnet_ids
    eks_cluster_role_name = "terraform-practice-module-cluster-role"
    eks_access_level = {user-1 = {user = "user-1", principal_arn = aws_iam_user.test.arn, access_policy = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy", access_scope = "cluster", namespace = "all"}}
    eks_access_entry_principal = {user-1 = aws_iam_user.test.arn}
    ng_name = "development-ng"
    instance_type = ["t2.micro"]
    capacity_type = "ON_DEMAND"
    ami_type = "AL2023_x86_64_STANDARD"
    ng_subnet_ids = module.vpc.public_subnet_ids
    ng_scaling_desired_count = 1
    ng_scaling_min_count = 1
    ng_scaling_max_count = 2
}

resource "aws_iam_user" "test" {
    name = "terraform-module"
}