output "vpc_id" {
    value = module.vpc.vpc_id
}

output "private_subnet_ids" {
    value = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
    value = module.vpc.public_subnet_ids
}

output "eks_cluster_name" {
    value = module.eks.cluster_name
}

output "eks_cluster_api_ep" {
    value = module.eks.eks_api_endpoint
}

output "eks_addons" {
    value = module.eks.eks_addons
}

output "eks_cluster_role_arn" {
    value = module.eks.eks_cluster_role_arn
}

output "eks_cluster_ng_role_arn" {
    value = module.eks.eks_cluster_ng_role_arn
}