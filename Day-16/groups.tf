#IAM group creation
resource "aws_iam_group" "education" {
    name = "education"
}

resource "aws_iam_group" "engineering" {
    name = "engineering"
}

resource "aws_iam_group" "managers" {
    name = "managers"
}

#Adding user into group
resource "aws_iam_group_membership" "education_members" {
    name = "education"
    users = [for user in aws_iam_user.all_users : user.name if user.tags.Department == "Education"]
    group = aws_iam_group.education.name   
}

resource "aws_iam_group_membership" "engineer_members" {
    name ="engineering"
    group = aws_iam_group.engineering.name
    users = [for user in aws_iam_user.all_users : user.name if user.tags.Department == "Engineering"]
}

resource "aws_iam_group_membership" "manager_members" {
    name = "manager"
    group = aws_iam_group.managers.name
    users = [for user in aws_iam_user.all_users : user.name if can(regex("Manager", user.tags.Job_Title))]
}