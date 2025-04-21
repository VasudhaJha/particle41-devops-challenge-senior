/*
[aws_iam_role.ecs_instance] (EC2 Role)
   |
   ↓ assumed by EC2 instances
[aws_iam_role_policy_attachment.ecs_policy]
   |
   ↓ attaches ECS permissions
[AmazonEC2ContainerServiceforEC2Role] (managed policy)
   |
   ↓ allows ECS agent on EC2 to:
     - Register to ECS cluster
     - Pull tasks
     - Send status/metrics

[aws_iam_instance_profile.ecs_instance]
   |
   ↓ used in Launch Template
[aws_launch_template.ecs]
   |
   ↓ attached to EC2 via ASG
[EC2 Instance]
   |
   ↓ ECS agent runs with this IAM role
   |
   ↓ Registers with ECS cluster automatically
*/


resource "aws_iam_role" "ecs_instance" {
  name = "${var.project}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_policy" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${var.project}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance.name
}
