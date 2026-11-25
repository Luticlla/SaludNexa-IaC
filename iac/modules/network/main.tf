locals {
  public_subnets = {
    a = {
      cidr    = var.public_subnet_cidrs.a
      az      = var.availability_zones.primary
      purpose = "nat-and-alb"
    }
    b = {
      cidr    = var.public_subnet_cidrs.b
      az      = var.availability_zones.secondary
      purpose = "alb-only"
    }
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-igw"
  })
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-public-${each.key}"
    Tier    = "public"
    Purpose = each.value.purpose
  })
}

resource "aws_subnet" "app" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.app_subnet_cidr
  availability_zone       = var.availability_zones.primary
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-app-a"
    Tier    = "private"
    Purpose = "ecs-fargate"
  })
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-eip"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  allocation_id     = aws_eip.nat.id
  subnet_id         = aws_subnet.public["a"].id
  connectivity_type = "public"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-a"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-rt"
  })
}

resource "aws_route_table_association" "app" {
  subnet_id      = aws_subnet.app.id
  route_table_id = aws_route_table.private.id
}

data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "flow" {
  name              = "/aws/vpc-flow-logs/${var.name_prefix}"
  retention_in_days = var.flow_log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-flow-logs"
  })
}

data "aws_iam_policy_document" "flow_logs" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role" "flow_logs" {
  name               = "${var.name_prefix}-vpc-flow-logs"
  assume_role_policy = data.aws_iam_policy_document.flow_logs.json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-flow-logs"
  })
}

data "aws_iam_policy_document" "flow_logs_write" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["${aws_cloudwatch_log_group.flow.arn}:*"]
  }
}

resource "aws_iam_role_policy" "flow_logs" {
  name   = "${var.name_prefix}-vpc-flow-logs"
  role   = aws_iam_role.flow_logs.id
  policy = data.aws_iam_policy_document.flow_logs_write.json
}

resource "aws_flow_log" "this" {
  vpc_id                   = aws_vpc.this.id
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.flow.arn
  iam_role_arn             = aws_iam_role.flow_logs.arn
  max_aggregation_interval = 600

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-flow-log"
  })

  depends_on = [aws_iam_role_policy.flow_logs]
}
