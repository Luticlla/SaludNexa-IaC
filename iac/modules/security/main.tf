locals {
  alb_ports = {
    http  = 80
    https = 443
  }

  task_ports = { for port in var.service_ports : tostring(port) => port }
}

resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Controls traffic to and from the public ALB."
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alb-sg"
  })
}

resource "aws_security_group" "tasks" {
  name        = "${var.name_prefix}-tasks-sg"
  description = "Controls traffic to and from the ECS tasks."
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-tasks-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  for_each = local.alb_ports

  security_group_id = aws_security_group.alb.id
  description       = "Allow public HTTP and HTTPS traffic to the ALB."
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = each.value
  to_port           = each.value
  ip_protocol       = "tcp"
  tags              = var.tags
}

resource "aws_vpc_security_group_egress_rule" "alb_to_tasks" {
  for_each = local.task_ports

  security_group_id            = aws_security_group.alb.id
  description                  = "Allow the ALB to reach ECS tasks on their container ports."
  referenced_security_group_id = aws_security_group.tasks.id
  from_port                    = each.value
  to_port                      = each.value
  ip_protocol                  = "tcp"
  tags                         = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "tasks_from_alb" {
  for_each = local.task_ports

  security_group_id            = aws_security_group.tasks.id
  description                  = "Allow only the ALB to reach ECS tasks on their container ports."
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = each.value
  to_port                      = each.value
  ip_protocol                  = "tcp"
  tags                         = var.tags
}

resource "aws_vpc_security_group_egress_rule" "tasks_all" {
  security_group_id = aws_security_group.tasks.id
  description       = "Allow ECS tasks outbound access through the NAT gateway."
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  tags              = var.tags
}
