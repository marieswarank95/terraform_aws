variable "region" {
    type = string
    default = "us-east-1"
}

variable "bucket_names" {
    type = list(string)
    default = ["terraform-practice-bucket-data-01", "terraform-practice-bucket-data-03"]
}

variable "tags" {
    type = map(string)
    default = {Created_by="Terraform", Environment="UAT"}
}

variable "bucket_names_1" {
    type = set(string)
    default = ["terraform-parctice-bucket-data-04", "terraform-parctice-bucket-data-06"]
}