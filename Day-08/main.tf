#count meta argument example
resource "aws_s3_bucket" "test_bucket" {
    count = length(var.bucket_names)
    bucket = var.bucket_names[count.index]
    tags = var.tags
}

#for_each meta argument example
resource "aws_s3_bucket" "for_each_bucket" {
    for_each = var.bucket_names_1
    bucket = each.value
    tags = var.tags
}