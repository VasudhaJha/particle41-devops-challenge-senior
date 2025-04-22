# Infrastructure Setup for SimpleTimeService with Terraform

This Terraform configuration provisions the infrastructure needed to run the SimpleTimeService application on AWS using ECS with EC2 launch type. It includes:

- networking
- auto scaling group with launch template to launch EC2 instances
- an application load balancer to route traffic to EC2 instances
- and an ECS cluster with task definition and ECS service to run SimpleTimeService
- IAM roles

## Prerequisites

- An AWS account
- [Terraform](https://developer.hashicorp.com/terraform/downloads) CLI v1.3 or later
- AWS credentials configured in your local environment (via `~/.aws/credentials`, `aws configure`, or environment variables like `AWS_ACCESS_KEY_ID`)

## Authenticating to AWS

Before running Terraform, ensure that your AWS credentials are available to the Terraform CLI. You can authenticate using:

- `aws configure`
- Environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, etc.)
- An IAM role if running from within GitHub Actions or another CI/CD pipeline

## Remote Backend Setup

Before running `terraform init`, you must provision the S3 bucket that acts as the remote backend. Either use the AWS CLI to do this or use the remote backend configuration declared in `remote_backend.tf` in the `Terraform` folder.

Using this configuration will create an `S3` bucket with versioning and server-side encryption.

## State locking

This project does not provision extra infrastructure for state locking. It employs lock file-based state locking mechanism using `use_lockfile = true` in the backend configuration block which allows using the `S3` remote backend bucket for state locking too.

This avoids the need for DynamoDB-based locking while still ensuring state safety.

## Deploying the Infrastructure

Once the backend is set up:

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

## Terraform Best Practices

- Uses variables with defaults (see `terraform.tfvars`)
- S3 remote backend with locking (via `use_lockfile = true`)
- No credentials committed in Git (uses IAM Role with trust policy for GitHub OIDC)
