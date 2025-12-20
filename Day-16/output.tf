output "user_names" {
    value = [for username, user_info in aws_iam_user.all_users: username]
}

output "user_password" {
    value = aws_iam_user_login_profile.console_access
    sensitive = true
}