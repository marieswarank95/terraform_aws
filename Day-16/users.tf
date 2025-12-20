#IAM user creation
resource "aws_iam_user" "all_users" {
    for_each = {for user in local.users : user.first_name => user}
    name = lower("${substr(each.value.first_name, 0, 1)}${each.value.last_name}")
    tags = {
        Department = each.value.department
        Job_Title = each.value.job_title
        Display_name = lower("${each.value.first_name}${each.value.last_name}")
    }
}

#To give console access to IAM users
resource "aws_iam_user_login_profile" "console_access" {
    for_each = {for user in aws_iam_user.all_users : user.name => user}
    user = each.key
    #password_length = 15
    #password_reset_required = true
    #pgp_key = keybase:username  # This key will be used to encrypt the password that is returned by AWS. Then we need to use decryption key to view the actual password.
}