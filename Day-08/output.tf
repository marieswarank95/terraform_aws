output "count_bucket_names" {
    value = [for bucket_name in aws_s3_bucket.test_bucket : bucket_name.id ]
}

output "count_bucket_arn" {
    value = [for bucket in aws_s3_bucket.test_bucket : bucket.arn]
}

output "for_each_bucket_names" {
    value = [for bucket_name in aws_s3_bucket.for_each_bucket : bucket_name.id ]
}

output "for_each_bucket_arn" {
    value = [for bucket in aws_s3_bucket.for_each_bucket : bucket.arn]
}