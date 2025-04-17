variable "region" {
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