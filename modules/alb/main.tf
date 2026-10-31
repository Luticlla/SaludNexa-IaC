locals {
  service_priorities = { for index, name in keys(var.services) : name => index + 1 }
  target_group_names = { for name in keys(var.services) : name => substr(lower("${var.name_prefix}-${name}-tg"), 0, 32) }
}

resource "aws_lb" "this" {
  name               = substr(lower("${var.name_prefix}-alb"), 0, 32)
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alb"
  })
}

resource "aws_lb_target_group" "this" {
  for_each = var.services

  name        = local.target_group_names[each.key]
  port        = each.value.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  deregistration_delay = 30

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = var.health_check_matcher
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(var.tags, {
    Name = local.target_group_names[each.key]
  })
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.certificate_arn == "" ? 80 : 443
  protocol          = var.certificate_arn == "" ? "HTTP" : "HTTPS"
  ssl_policy        = var.certificate_arn == "" ? null : "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn == "" ? null : var.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alb-listener"
  })
}

resource "aws_lb_listener_rule" "this" {
  for_each = var.services

  listener_arn = aws_lb_listener.this.arn
  priority     = local.service_priorities[each.key]

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }

  condition {
    path_pattern {
      values = [each.value.route]
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.key}-rule"
  })
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_rate" {
  alarm_name        = "${var.name_prefix}-alb-5xx-rate-high"
  alarm_description = "ALB 5xx error rate above ${var.alb_5xx_threshold_percent}% of requests."

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alb_5xx_evaluation_periods
  threshold           = var.alb_5xx_threshold_percent
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.alarm_actions

  metric_query {
    id          = "error_rate"
    expression  = "100 * errors / requests"
    label       = "ALB 5xx rate (%)"
    return_data = true
  }

  metric_query {
    id = "errors"

    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "HTTPCode_ELB_5XX_Count"
      dimensions  = { LoadBalancer = aws_lb.this.arn_suffix }
      period      = 300
      stat        = "Sum"
    }
  }

  metric_query {
    id = "requests"

    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "RequestCount"
      dimensions  = { LoadBalancer = aws_lb.this.arn_suffix }
      period      = 300
      stat        = "Sum"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alb-5xx-rate-high"
  })
}
