# ──────────────────────────────────────────────────────────────────────────────────────────────────
# CloudWatch Log Group (explicit, with retention) - created before the function to control retention
# ──────────────────────────────────────────────────────────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
  tags = merge(
    var.tags,
    {
      Name        = "${var.tags.Project}-${var.tags.Environment}-lambda"
      Environment = var.tags.Environment
    }
  )
}

# ──────────────────────────────────────────────────────────────────────────────────────────────────
# Lambda Function
# ──────────────────────────────────────────────────────────────────────────────────────────────────
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  description   = var.description
  role          = aws_iam_role.lambda.arn

  # Source – choose package_type IMAGE or Zip
  package_type = var.package_type

  # Zip-based deployment
  filename         = var.package_type == "Zip" ? var.filename : null
  source_code_hash = var.package_type == "Zip" ? var.source_code_hash : null
  handler          = var.package_type == "Zip" ? var.handler : null
  runtime          = var.package_type == "Zip" ? var.runtime : null

  # Container image-based deployment
  image_uri = var.package_type == "Image" ? var.image_uri : null

  memory_size                    = var.memory_size
  timeout                        = var.timeout
  reserved_concurrent_executions = var.reserved_concurrency

  # Environment variables
  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  # VPC configuration (optional)
  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  # Dead-letter queue (optional)
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_arn != null ? [1] : []
    content {
      target_arn = var.dead_letter_arn
    }
  }

  # Tracing (X-Ray)
  tracing_config {
    mode = var.tracing_mode
  }

  # Layers (optional)
  layers = var.layer_arns

  # Ensure log group exists before function
  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.basic_execution,
  ]

  tags = merge(
    var.tags,
    {
      Name        = "${var.tags.Project}-${var.tags.Environment}-lambda"
      Environment = var.tags.Environment
    }
  )
}

# ─────────────────────────────────────────────
# Lambda Aliases (e.g. "live", "canary")
# ─────────────────────────────────────────────
resource "aws_lambda_alias" "this" {
  for_each = var.aliases

  name             = each.key
  function_name    = aws_lambda_function.this.function_name
  function_version = each.value.function_version

  dynamic "routing_config" {
    for_each = each.value.additional_version_weights != null ? [1] : []
    content {
      additional_version_weights = each.value.additional_version_weights
    }
  }
}

# ─────────────────────────────────────────────
# Event Source Mappings (SQS / DynamoDB / Kinesis)
# ─────────────────────────────────────────────
resource "aws_lambda_event_source_mapping" "this" {
  for_each = var.event_source_mappings

  event_source_arn                   = each.value.event_source_arn
  function_name                      = aws_lambda_function.this.arn
  batch_size                         = lookup(each.value, "batch_size", 10)
  starting_position                  = lookup(each.value, "starting_position", null)
  enabled                            = lookup(each.value, "enabled", true)
  bisect_batch_on_function_error     = lookup(each.value, "bisect_batch_on_error", false)
  maximum_batching_window_in_seconds = lookup(each.value, "batching_window_seconds", 0)
}

# ─────────────────────────────────────────────
# Lambda Permission (resource-based policy)
# ─────────────────────────────────────────────
resource "aws_lambda_permission" "this" {
  for_each = var.allowed_triggers

  statement_id  = each.key
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = each.value.principal
  source_arn    = lookup(each.value, "source_arn", null)
  qualifier     = lookup(each.value, "qualifier", null)
}
