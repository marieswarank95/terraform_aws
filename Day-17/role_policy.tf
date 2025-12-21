#EC2 IAM role creation
resource "aws_iam_role" "ec2_role" {
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
            Service = "ec2.amazonaws.com"
            }
        }
        ]
    })
    description = "This role is created for EC2 under EB environment."
    name = "EB-EC2-Role"
}

resource "aws_iam_policy_attachment" "ec2_policy_attach" {
    for_each = var.ec2_policies_arn
    name = "eb-ec2-attachment"
    roles = [aws_iam_role.ec2_role.name]
    policy_arn = each.value

}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
    name = "EB-EC2-Role"
    role = aws_iam_role.ec2_role.name
}