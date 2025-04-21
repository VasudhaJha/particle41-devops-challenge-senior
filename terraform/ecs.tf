/*
ECS Cluster and Service Setup

[Application Load Balancer] (public subnet)
   |
   ↓ forwards HTTP requests
[Target Group (port 80)]  <-- type = instance
   |
   ↓ registers EC2 host of ECS task
[ECS Service]
   |
   ↓ manages task lifecycle
[ECS Task Definition]
   |
   ↓ runs Docker container
[Docker Container]
   |
   ↓ uses "bridge" networking
[EC2 Instance (from ASG)] (in private subnet)
   |
   ↓ must allow inbound traffic from ALB SG (port 80)

Networking notes:
- ECS Task runs on EC2 instance using "bridge" mode
- ALB must talk to EC2 hostPort:80 (not container IP)
- ECS task is registered in the Target Group as an EC2 target
- ECS Service maintains the desired count (e.g. 1) of running containers
- Security group for EC2 allows ALB SG to talk to port 80
*/

resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  tags = merge(var.common_tags, {
    Name = var.cluster_name
  })
}

resource "aws_ecs_task_definition" "simple_time_service" {
  family                   = "${var.project}-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "256"
  memory                   = "512"
  container_definitions    = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "simple_time_service" {
  name            = "${var.project}-service"
  cluster         = aws_ecs_cluster.main.id
  launch_type     = "EC2"
  desired_count   = 1
  task_definition = aws_ecs_task_definition.simple_time_service.arn

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name   = var.container_name
    container_port   = 8000
  }

  depends_on = [
    aws_lb_listener.ecs
  ]

  tags = merge(var.common_tags, {
    Name = "${var.project}-ecs-service"
  })
}



