resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  tags = merge(var.common_tags, {
    Name = var.cluster_name
  })
}
