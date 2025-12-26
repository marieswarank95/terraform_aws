output "eks_api_endpoint" {
    value = aws_eks_cluster.eks.endpoint
}

output "cluster_name" {
    value = aws_eks_cluster.eks.id
}

output "eks_addons" {
    value = [for addon in aws_eks_addon.addons : addon.id]
}

output "eks_cluster_role_arn" {
    value = aws_iam_role.eks_cluster_role.arn
}

output "eks_cluster_ng_role_arn" {
    value = aws_iam_role.eks_ng_role.arn
}