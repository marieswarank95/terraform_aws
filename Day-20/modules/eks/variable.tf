#EKS cluster variable

variable "eks_cluster_name" {
    type = string
}

variable "kubernetes_version" {
    type = string
}

variable "eks_authentication_mode" {
    type = string
}

variable "eks_scaling_tier" {
    type = string
}

variable "eks_upgrade_policy" {
    type = string
}

variable "eks_logging" {
    type = set(string)
}

variable "eks_deletion_protection" {
    type = bool
}

variable "eks_api_private_access" {
    type = bool
}

variable "eks_api_public_access" {
    type = bool
}

variable "eks_access_cidrs" {
    type = set(string)
}

variable "eks_subnet_ids" {
    type = set(string)
}

variable "eks_access_entry_principal" {
    type = map(string)
}

variable "eks_access_level" {
    type = map(object({user = string, principal_arn = string, access_policy = string, access_scope = string, namespace = string}))
}

variable "eks_cluster_role_name" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "eks_cluster_ng_policy" {
    type = set(string)
    default = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
}

variable "ng_subnet_ids" {
    type = set(string)
}

variable "ng_scaling_desired_count" {
    type = number
}

variable "ng_scaling_min_count" {
    type = number
}

variable "ng_scaling_max_count" {
    type = number
}

variable "ami_type" {
    type = string
}

variable "capacity_type" {
    type = string
}

variable "instance_type" {
    type = list(string)
}

variable "ng_name" {
    type = string
}

variable "addons" {
    type = set(string)
    default = ["coredns", "kube-proxy", "vpc-cni"]
}