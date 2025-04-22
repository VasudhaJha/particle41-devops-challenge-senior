/*
[Launch Template]
   |
   ↓ provides config to...
[Auto Scaling Group]
   |
   ↓ launches
[EC2 Instances (in private subnets)]
   |
   ↓ runs ECS agent (via user_data)
   |
   ↓ registers with ECS Cluster

Key elements in the Launch Template:
- AMI: ECS-optimized Amazon Linux 2023 (via SSM parameter)
- Instance type: defined by variable
- IAM role: allows EC2 to interact with ECS, CloudWatch, etc.
- user_data:
   - Configures ECS_CLUSTER=your-cluster-name
   - Starts ECS agent on boot
- Tags, security group, and block device mappings can also be added

Notes:
- Used by ASG to create EC2 instances that are ECS-ready
- user_data is the most critical piece — it registers EC2 with your ECS cluster
*/

# ECS-optimized AMI
data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

# Launch Template
resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.project}-ecs-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.ec2_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance.name
  }

  user_data = base64encode(<<-EOF
  #!/bin/bash
  echo "ECS_CLUSTER=${var.cluster_name}" > /etc/ecs/ecs.config
  echo "ECS_CONTAINER_INSTANCE_PROPAGATE_TAGS_FROM=ec2_instance" >> /etc/ecs/ecs.config
  EOF
  )

  vpc_security_group_ids = [aws_security_group.ecs_tasks.id]

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.project}-ecs-instance"
    })
  }
}

resource "aws_security_group" "ecs_tasks" {
  name   = "${var.project}-ecs-task-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Allow traffic from ALB"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project}-ecs-task-sg"
  })
}
