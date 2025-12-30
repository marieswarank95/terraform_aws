data "aws_caller_identity" "current" {
}

#S3 bucket creation and its related configuration for AWS Config to store configuration data
resource "aws_s3_bucket" "config_bucket" {
    bucket = "terraform-practice-bucket-aws-config"
    force_destroy = true
    tags = {
        environment = "demo"
    }
}

resource "aws_s3_bucket_versioning" "config_bucket" {
    bucket = aws_s3_bucket.config_bucket.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config_bucket" {
    bucket = aws_s3_bucket.config_bucket.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_public_access_block" "config_bucket" {
    bucket = aws_s3_bucket.config_bucket.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "config_bucket" {
    bucket = aws_s3_bucket.config_bucket.id
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
            "Sid": "Statement1",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": [
                "s3:GetBucketAcl",
                "s3:ListBucket"
            ],
            "Resource": aws_s3_bucket.config_bucket.arn
            },
            {
            "Sid": "Statement2",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": [
                "s3:PutObject"
            ],
            "Resource": "${aws_s3_bucket.config_bucket.arn}/*",
            "Condition": {
                "StringEquals": {
                "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
            },
            {
            "Sid": "Statement3",
            "Effect": "Deny",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "s3:*",
            "Resource": ["${aws_s3_bucket.config_bucket.arn}/*", aws_s3_bucket.config_bucket.arn],
            "Condition": {
                "Bool": {
                "aws:SecureTransport": "false"
                }
            }
            }
        ]
        })
}

#============================================================#

#AWS config service enablement and its configuration 
resource "aws_config_configuration_recorder" "config" {
    name = "terraform-config"
    role_arn = aws_iam_role.config.arn
    recording_group {
        all_supported = true
        include_global_resource_types = true
    }
}

resource "aws_config_delivery_channel" "config" {
    name = "terraform-config-delivery-channel"
    s3_bucket_name = aws_s3_bucket.config_bucket.id
    depends_on = [aws_config_configuration_recorder.config]
}

resource "aws_config_configuration_recorder_status" "config" {
    name = aws_config_configuration_recorder.config.id
    is_enabled = true
    depends_on = [aws_config_delivery_channel.config]
}

resource "aws_config_config_rule" "s3-public-write-restriction" {
    name = "S3-Public-Write-Restriction"
    description = "This rule evaluate any S3 allowed to upload object without authentication."
    source {
        owner = "AWS"
        source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
    }
    depends_on = [aws_config_configuration_recorder.config]
}

resource "aws_config_config_rule" "s3-public-read-restriction" {
    name = "S3-Public-Read-Restriction"
    description = "This rule evaluate any S3 allowed to get object without authentication."
    source {
        owner = "AWS"
        source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
    }
    depends_on = [aws_config_configuration_recorder.config]
}

resource "aws_config_config_rule" "s3-sse-enabled" {
    name = "S3-SSE"
    description = "This rule evaluate whether SSE enabled in S3 or not."
    source {
        owner = "AWS"
        source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
    }
    depends_on = [aws_config_configuration_recorder.config]
}

resource "aws_config_config_rule" "ebs_encryption" {
    name = "EBS-Encryption"
    description = "This rule will check whether the ebs encrypted by default or not."
    source {
        owner = "AWS"
        source_identifier = "EC2_EBS_ENCRYPTION_BY_DEFAULT"
    }
    depends_on = [aws_config_configuration_recorder.config]
}

resource "aws_config_config_rule" "ec2_tags" {
    name = "EC2-tags"
    description = "It checks whether the EC2 instance has the mentioned tags or not."
    source {
        owner = "AWS"
        source_identifier = "REQUIRED_TAGS"
    }
    input_parameters = jsonencode({
        tag1Key = "Environment"
        tag1Value = "Dev,QA,Prod"
        tag2Key = "owner"
    })
    scope {
        compliance_resource_types = ["AWS::EC2::Instance"]
    }
    depends_on = [aws_config_configuration_recorder.config]
}

resource "aws_config_config_rule" "root_mfa" {
    name = "ROOT-Account_MFA"
    description = "It checks whether the root account has mfa or not."
    source {
        owner = "AWS"
        source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
    }
    depends_on = [aws_config_configuration_recorder.config]
}

#==================================================#

#IAM User, Policy and Role creation
resource "aws_iam_policy" "enforce_s3_delete_obj_withmfa" {
    name = "S3-object-delete-deny-without-mfa"
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
            "Sid": "Statement1",
            "Effect": "Deny",
            "Action": [
                "s3:DeleteObject"
            ],
            "Resource": "*",
            "Condition": {
                "BoolIfExists": {
                "aws:MultiFactorAuthPresent": "false"
                }
            }
            }
        ]
        })
}

resource "aws_iam_policy" "enforce_s3_upload_secure" {
    name = "S3-secure-object-upload"
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
            "Sid": "Statement1",
            "Effect": "Deny",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                "aws:SecureTransport": "false"
                }
            }
            }
        ]
        })
}

resource "aws_iam_policy" "enforce_ec2_tag" {
    name = "enforce_ec2_tags"
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
            "Sid": "Statement1",
            "Effect": "Deny",
            "Action": [
                "ec2:RunInstances"
            ],
            "Resource": "arn:aws:ec2:*:*:instance/*",
            "Condition": {
                "StringNotLike": {
                "aws:RequestTag/Environment": ["Dev", "QA", "Prod"]
                }
            }
            },
        {
            "Sid": "Statement2",
            "Effect": "Allow",
            "Action": [
                "ec2:RunInstances"
            ],
            "Resource": "arn:aws:ec2:*:*:instance/*",
            "Condition": {
                "Null": {
                "aws:ResourceTag/Owner": "true"
                }
            }
            }
        ]
        })
}

resource "aws_iam_user" "tf_test_user" {
    name = "terraform-test-user"
}

resource "aws_iam_user_policy_attachment" "tf_test_user_mfa" {
    user = aws_iam_user.tf_test_user.id
    policy_arn = aws_iam_policy.enforce_s3_delete_obj_withmfa.arn
}

resource "aws_iam_user_policy_attachment" "tf_test_user_enforce_s3_upload_secure" {
    user = aws_iam_user.tf_test_user.id
    policy_arn = aws_iam_policy.enforce_s3_upload_secure.arn
}

resource "aws_iam_user_policy_attachment" "tf_test_user_ec2_tags" {
    user = aws_iam_user.tf_test_user.id
    policy_arn = aws_iam_policy.enforce_ec2_tag.arn
}

resource "aws_iam_user_login_profile" "tf_test_user" {
    user = aws_iam_user.tf_test_user.id
}

resource "aws_iam_role" "config" {
    name = "AWS_Config_service_role"
    assume_role_policy = jsonencode({
        "Version":"2012-10-17",		 	 	 
        "Statement": [
            {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Action": "sts:AssumeRole",
            }
        ]
        })
}

resource "aws_iam_role_policy" "config_s3_access_policy" {
    role = aws_iam_role.config.id
    name = "AWS-Config-S3-access"
    policy = jsonencode({
        "Version":"2012-10-17",		 	 	 
        "Statement":[
            {
            "Effect":"Allow",
            "Action":[
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource":[
                "${aws_s3_bucket.config_bucket.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
            ],
            "Condition":{
                "StringLike":{
                "s3:x-amz-acl":"bucket-owner-full-control"
                }
            }
            },
            {
            "Effect":"Allow",
            "Action":[
                "s3:GetBucketAcl"
            ],
            "Resource":aws_s3_bucket.config_bucket.arn
            }
        ]
        })
}

resource "aws_iam_role_policy_attachment" "config_recorder_access" {
    role = aws_iam_role.config.id
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}