region = "ap-south-1"
project = "particle41-devops-challenge"
common_tags = {
  "Project"   = "particle41-devops-challenge"
  "ManagedBy" = "Terraform"
}
remote_backend_name = "particle41-devops-challenge-vasudha"
vpc_cidr_block = "10.0.0.0/16"

cluster_name = "particle41-ecs"