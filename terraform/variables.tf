variable "region" {
  description = "AWS region to deploy infrastructure"
  type = string
}

variable "project" {
  description = "AWS region to deploy infrastructure"
  type = string
}

variable "common_tags" {
  description = "Tags for all AWS resources"
  type = map(string)
}

variable "remote_backend_name" {
  description = "Name of the S3 bucket which serves as the remote backend"
  type = string
}

variable "vpc_cidr_block" {
  description = "CIDR range for the VPC"
  type = string
}

variable "cluster_name" {
  description = "The name of the ECS cluster"
  type = string
}