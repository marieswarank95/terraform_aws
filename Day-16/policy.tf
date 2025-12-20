#IAM policy creation
resource "aws_iam_policy" "engineering_group_policy" {
    name = "Engineering-Team"
    description = "Created by Terraform."
    policy = file("engineering_group_policy.json") # Read the content of the file that has info about the policy.
}

resource "aws_iam_policy" "managers_group_policy" {
    name = "Managers-Team"
    description = "Created by Terraform."
    policy = file("manager_group_policy.json")
}

#IAM policy attachment with IAM group
resource "aws_iam_group_policy_attachment" "policy_attachment_1" {
    group = aws_iam_group.engineering.name
    policy_arn = aws_iam_policy.engineering_group_policy.arn
}

resource "aws_iam_group_policy_attachment" "policy_attachment_2" {
    group = aws_iam_group.managers.name
    policy_arn = aws_iam_policy.managers_group_policy.arn
}