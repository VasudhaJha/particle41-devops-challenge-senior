/*
Application Load Balancer Setup (public-facing)

Internet (port 80)
   |
[Application Load Balancer] <-- in public subnets
   |
[Listens on port 80]
   ↓
[Target Group (target_type = "instance")] <-- routes to ECS EC2 instances
   ↓
[Container inside ECS EC2] (must match containerPort + hostPort)

*/

resource "aws_lb" "ecs" {
  name               = "${var.project}-alb"
  load_balancer_type = "application"
  subnets            = values(aws_subnet.public)[*].id
  security_groups    = [aws_security_group.alb.id]

  tags = merge(var.common_tags, {
    Name = "${var.project}-alb"
  })
}

resource "aws_security_group" "alb" {
  name   = "${var.project}-alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project}-alb-sg"
  })
}

resource "aws_lb_target_group" "ecs" {
  name     = "${var.project}-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project}-tg"
  })

  #depends_on = [aws_lb_listener.ecs] 
}

resource "aws_lb_listener" "ecs" {
  load_balancer_arn = aws_lb.ecs.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }

  #depends_on = [aws_ecs_service.simple_time_service]
}

