data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "kms" {
  statement {
    sid    = "AdministracionCuenta"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]

    resources = ["*"]

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"]
    }
  }

  statement {
    sid    = "CloudWatchAlarms"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]

    resources = ["*"]
  }
}

resource "aws_kms_key" "this" {
  description             = "Clave para cifrar logs y alertas de ${var.name_prefix}."
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.kms.json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-observabilidad"
  })
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.name_prefix}-observabilidad"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_sns_topic" "alerts" {
  name              = "${var.name_prefix}-alertas"
  kms_master_key_id = aws_kms_key.this.arn

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alertas"
  })
}

resource "aws_sns_topic_subscription" "email" {
  count = var.alert_email == "" ? 0 : 1

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_dashboard" "operations" {
  dashboard_name = "${var.name_prefix}-operacion"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title   = "CPU por servicio (ECS)"
          region  = data.aws_region.current.name
          view    = "timeSeries"
          stat    = "Average"
          period  = 300
          metrics = [for service in values(var.service_names) : ["AWS/ECS", "CPUUtilization", "ClusterName", var.cluster_name, "ServiceName", service]]
          yAxis   = { left = { min = 0, max = 100 } }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title   = "Tareas en ejecución (Container Insights)"
          region  = data.aws_region.current.name
          view    = "timeSeries"
          stat    = "Average"
          period  = 300
          metrics = [for service in values(var.service_names) : ["ECS/ContainerInsights", "RunningTaskCount", "ClusterName", var.cluster_name, "ServiceName", service]]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title   = "Peticiones al ALB"
          region  = data.aws_region.current.name
          view    = "timeSeries"
          period  = 300
          metrics = [["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix, { stat = "Sum" }]]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "Errores 5xx del ALB"
          region = data.aws_region.current.name
          view   = "timeSeries"
          period = 300
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", var.alb_arn_suffix, { stat = "Sum" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix, { stat = "Sum" }],
          ]
        }
      },
    ]
  })
}
