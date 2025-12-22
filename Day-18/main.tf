#Source S3 bucket creation
resource "aws_s3_bucket" "source_bucket" {
    bucket = var.source_bucket
    force_destroy = true  # only give this option to delete this bucket intentionally.
}

resource "aws_s3_bucket_versioning" "source_bucket" {
    bucket = aws_s3_bucket.source_bucket.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "source_bucket" {
    bucket = aws_s3_bucket.source_bucket.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_public_access_block" "source_bucket" {
    bucket = aws_s3_bucket.source_bucket.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}


#Destination S3 bucket creation
resource "aws_s3_bucket" "destination_bucket" {
    bucket = var.destination_bucket
    force_destroy = true # only give this option to delete this bucket intentionally.
}

resource "aws_s3_bucket_versioning" "destination_bucket" {
    bucket = aws_s3_bucket.destination_bucket.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "destination_bucket" {
    bucket = aws_s3_bucket.destination_bucket.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_s3_bucket_public_access_block" "destination_bucket" {
    bucket = aws_s3_bucket.destination_bucket.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

#lambda layer creation for dependency package
resource "aws_lambda_layer_version" "image_processing_layer" {
    layer_name = "python_dependency"
    compatible_architectures = ["x86_64"]
    compatible_runtimes = ["python3.12"]
    description = "This layer contains the pillow python module."
    filename = "pillow_layer.zip"
}

data "archive_file" "lambda_image_processing_function" {
    type = "zip"
    source_file = "lambda_function.py"
    output_path = "${path.module}/lambda_function.zip"  # This file directory.
}

# IAM role creation for lambda function
resource "aws_iam_role" "lambda_role" {
    assume_role_policy = jsonencode({
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "lambda.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        })
    description = "This IAM role for image processing lambda function."
    name = "lambda-function-image-processing"
}

#IAM role inline policy creation
resource "aws_iam_role_policy" "lambda_role_inline_policy" {
    name = "s3-cloudwatch-log-group-access"
    policy = jsonencode({
                "Version": "2012-10-17",
                "Statement": [
                    {
                    "Sid": "Statement1",
                    "Effect": "Allow",
                    "Action": [
                        "s3:GetObject",
                        "s3:GetObjectVersion"
                    ],
                    "Resource": "${aws_s3_bucket.source_bucket.arn}/*"
                    },
                    {
                    "Sid": "Statement2",
                    "Effect": "Allow",
                    "Action": [
                        "s3:PutObject",
                        "s3:PutObjectAcl"
                    ],
                    "Resource": "${aws_s3_bucket.destination_bucket.arn}/*"
                    },
                    {
                    "Sid": "Statement3",
                    "Effect": "Allow",
                    "Action": [
                        "logs:CreateLogGroup",
                        "logs:CreateLogStream",
                        "logs:PutLogEvents"
                    ],
                    "Resource": "*"
                    }
                ]
                })
    role = aws_iam_role.lambda_role.name
}

#lambda function creation
resource "aws_lambda_function" "image_processing" {
    function_name = "Image-Processing"
    role = aws_iam_role.lambda_role.arn
    architectures = ["x86_64"]
    description = "This function for image processing."
    environment {
        variables = {
            PROCESSED_BUCKET = aws_s3_bucket.destination_bucket.id
            LOG_LEVEL = "INFO"
        }
    }
    filename = data.archive_file.lambda_image_processing_function.output_path
    handler = "lambda_function.lambda_handler" #source code file name + function name
    layers = [ aws_lambda_layer_version.image_processing_layer.arn ]
    memory_size = "128"
    package_type = "Zip"
    runtime = "python3.12"
    timeout = 60
}

#S3 bucket event notification
resource "aws_s3_bucket_notification" "s3_lambda_notify" {
    bucket = aws_s3_bucket.source_bucket.id
    lambda_function {
        events = ["s3:ObjectCreated:*"]
        lambda_function_arn = aws_lambda_function.image_processing.arn
    }
}

#lambda permission for S3 bucket to invoke lambda function
resource "aws_lambda_permission" "image_processing" {
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.image_processing.arn
    principal = "s3.amazonaws.com"
    source_arn = aws_s3_bucket.source_bucket.arn
}