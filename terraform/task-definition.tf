# resource "aws_ecs_task_definition" "simple_time_service" {
#   family                   = "${var.project}-task"
#   requires_compatibilities = ["EC2"]
#   network_mode             = "bridge"
#   cpu                      = "256"
#   memory                   = "512"
#   container_definitions    = jsonencode([
#     {
#       name      = var.container_name
#       image     = var.container_image
#       essential = true
#       portMappings = [
#         {
#           containerPort = 80
#           hostPort      = 80
#         }
#       ]
#     }
#   ])
# }
