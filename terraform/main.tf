terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws",
        version = "~>5.0"
    }
  }
  backend "s3" {
    bucket       = "particle41-devops-vasudha"
    key          = "ecs-app/dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt        = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region
}