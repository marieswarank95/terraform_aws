#S3 remote backend example
resource "aws_s3_bucket" "test_bucket" {
    bucket = "terraform-practice-bucket-data"
    tags = {
        Name = "data-storage"
        environment = "development"
    }
}