#Mixed Type Constraints (Overall Deployment Summary) example
output "deployment_summary" {
    value = aws_vpc.project_vpc.tags_all
}