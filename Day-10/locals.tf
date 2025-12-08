locals {
    tags = {
        Name = "${var.environment}-Web-Instance"
        Environment = "${var.environment}"
    }
}