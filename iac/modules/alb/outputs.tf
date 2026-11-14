output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.this.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix of the ALB used by CloudWatch dimensions."
  value       = aws_lb.this.arn_suffix
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the Application Load Balancer."
  value       = aws_lb.this.zone_id
}

output "listener_arn" {
  description = "ARN of the ALB listener."
  value       = aws_lb_listener.this.arn
}

output "target_group_arns" {
  description = "Target group ARNs keyed by service name."
  value       = { for name, target_group in aws_lb_target_group.this : name => target_group.arn }
  depends_on  = [aws_lb_listener_rule.this]
}

output "target_group_names" {
  description = "Target group names keyed by service name."
  value       = { for name, target_group in aws_lb_target_group.this : name => target_group.name }
}

output "alb_5xx_alarm_arn" {
  description = "ARN of the ALB 5xx rate alarm."
  value       = aws_cloudwatch_metric_alarm.alb_5xx_rate.arn
}
