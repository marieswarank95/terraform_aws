#EKS cluster creation
resource "aws_eks_cluster" "eks" {
    name = var.eks_cluster_name
    role_arn = aws_iam_role.eks_cluster_role.arn
    version = var.kubernetes_version
    access_config {
        authentication_mode = var.eks_authentication_mode
    }
    control_plane_scaling_config {
        tier = var.eks_scaling_tier
    }
    upgrade_policy {
        support_type = var.eks_upgrade_policy
    }
    enabled_cluster_log_types = var.eks_logging
    deletion_protection = var.eks_deletion_protection
    vpc_config {
        endpoint_private_access = var.eks_api_private_access
        endpoint_public_access = var.eks_api_public_access
        public_access_cidrs = var.eks_access_cidrs
        security_group_ids = [aws_security_group.eks_cluster_sg.id]
        subnet_ids = var.eks_subnet_ids
    }
}

#EKS cluster access entry creation  -> It is for authentication to access the EKS cluster
resource "aws_eks_access_entry" "access_entry" {
    for_each = var.eks_access_entry_principal
    cluster_name = aws_eks_cluster.eks.id
    principal_arn = each.value
    type = "STANDARD"
}

#EKS cluster access policy for the access entry
resource "aws_eks_access_policy_association" "cluster_access_policy" {
    for_each = {for access_entry in var.eks_access_level : access_entry.user => access_entry if access_entry.access_scope == "cluster"} 
    cluster_name = aws_eks_cluster.eks.id
    principal_arn = each.value.principal_arn
    policy_arn = each.value.access_policy
    access_scope {
        type = "cluster"
    }
}

resource "aws_eks_access_policy_association" "namespace_access_policy" {
    for_each = {for access_entry in var.eks_access_level : access_entry.user => access_entry if access_entry.access_scope == "namespace"} 
    cluster_name = aws_eks_cluster.eks.id
    principal_arn = each.value.principal_arn
    policy_arn = each.value.access_policy
    access_scope {
        type = "namespace"
        namespaces = [each.value.namespace]
    }
}

#EKS cluster IAM role creation
resource "aws_iam_role" "eks_cluster_role" {
    name = var.eks_cluster_role_name
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

#attach managed IAM policy into the IAM role
resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy" {
    role = aws_iam_role.eks_cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

#node group IAM role creation
resource "aws_iam_role" "eks_ng_role" {
    name = "${var.eks_cluster_name}-ng-role"
    assume_role_policy = jsonencode({
            Version = "2012-10-17"
            Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid    = ""
                Principal = {
                Service = "ec2.amazonaws.com"
                }
            },
            ]
        })
}

#node group IAM role policy attachment
resource "aws_iam_role_policy_attachment" "ng_role_policy" {
    for_each = var.eks_cluster_ng_policy
    role = aws_iam_role.eks_ng_role.name
    policy_arn = each.value
} 

#EKS cluster and node group security group creation
resource "aws_security_group" "eks_cluster_sg" {
    name = "${var.eks_cluster_name}-eks-sg"
    description = "SG used by ${var.eks_cluster_name} EKS cluster"
    vpc_id = var.vpc_id
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "eks_cluster_ng_sg" {
    name = "${var.eks_cluster_name}-eks-ng-sg"
    description = "SG used by ${var.eks_cluster_name} EKS cluster node group"
    vpc_id = var.vpc_id
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

#communication between cluster node to node group
resource "aws_security_group_rule" "ng_sg_rule" {
    security_group_id = aws_security_group.eks_cluster_ng_sg.id
    type = "ingress"
    from_port = 1025
    to_port = 65535
    protocol = "tcp"
    source_security_group_id = aws_security_group.eks_cluster_sg.id
}

#communication between node group nodes
resource "aws_security_group_rule" "ng_sg_rule_1" {
    security_group_id = aws_security_group.eks_cluster_ng_sg.id
    type = "ingress"
    from_port = 1025
    to_port = 65535
    protocol = "tcp"
    self = true
}

#EKS cluster node group creation
resource "aws_eks_node_group" "eks_ng_group" {
    cluster_name = aws_eks_cluster.eks.id
    node_role_arn = aws_iam_role.eks_ng_role.arn
    scaling_config {
        desired_size = var.ng_scaling_desired_count
        min_size = var.ng_scaling_min_count
        max_size = var.ng_scaling_desired_count
    }
    subnet_ids = var.ng_subnet_ids
    ami_type = var.ami_type
    capacity_type = var.capacity_type
    instance_types = var.instance_type
    node_group_name = var.ng_name

    depends_on = [aws_iam_role_policy_attachment.ng_role_policy]
}

#EKS cluster add on
resource "aws_eks_addon" "addons" {
    for_each = var.addons
    cluster_name = aws_eks_cluster.eks.id
    addon_name = each.value
    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"
    depends_on = [aws_eks_node_group.eks_ng_group]
}