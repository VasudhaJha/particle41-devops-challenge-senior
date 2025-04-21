/*
[Private Subnets] <-- EC2 instances launched here
   |
   ↓
[Auto Scaling Group]
   |
   ↓ uses launch template
[Launch Template]
   |
   ↓ uses ECS-optimized AMI + user_data
[EC2 Instance]
   |
   ↓ runs ECS Agent, registers with ECS Cluster
[ECS Cluster]

Notes:
- ASG ensures desired number of ECS-capable EC2 instances are always running
- Uses the latest version of Launch Template
- Instances are launched into private subnets (not publicly accessible)
- Health checks ensure instances are healthy before considered "in service"
- Each instance runs ECS agent and joins the ECS Cluster via user_data
*/

resource "aws_autoscaling_group" "ecs" {
  name                      = "${var.project}-ecs-asg"
  desired_capacity          = 1       
  max_size                  = 2       
  min_size                  = 1       

  # Launch Template for instance config
  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  # Subnets to launch instances into
  vpc_zone_identifier = values(aws_subnet.private)[*].id

  # to create the ASG after subnets exist
  depends_on = [aws_subnet.private]

  tag {
    key                 = "Name"
    value               = "${var.project}-ecs-instance"
    propagate_at_launch = true
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
}
