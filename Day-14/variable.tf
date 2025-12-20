variable "bucket_name" {
    type = string
    default = "terraform-practice-bucket-web-static"
}

variable "tags" {
    type = map(string)
    default = {
        Name = "Web-Project"
        Environment = "Development"
    }
}