#S3 remote backend example
#S3 bucket creation
resource "aws_s3_bucket" "test_bucket" {
    bucket = "terraform-practice-bucket-data"
    tags = {
        Name = "data-storage"
        environment = "development"
    }
}

#Bucket versioning configuration
resource "aws_s3_bucket_versioning" "test_bucket_versioning" {
    bucket = aws_s3_bucket.test_bucket.id
    versioning_configuration {
        status = "Enabled"
    }
}

#Bucket encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "test_bucket_encryption" {
    bucket = aws_s3_bucket.test_bucket.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}