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

  # Optional: wait until at least one instance is running and healthy
  health_check_type         = "EC2"
  health_check_grace_period = 300
}
