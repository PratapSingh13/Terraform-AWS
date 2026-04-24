# ─────────────────────────────────────────────
# IAM Role for Lambda Execution
# ─────────────────────────────────────────────

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Execution role for the Lambda function
resource "aws_iam_role" "lambda" {
  name               = "${var.function_name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(
    var.tags,
    {
      Name        = "${var.tags.Project}-${var.tags.Environment}-lambda"
      Environment = var.tags.Environment
    }
  )
}

# Attach AWS managed basic execution policy
resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach VPC execution policy only when Lambda runs inside a VPC
resource "aws_iam_role_policy_attachment" "vpc_execution" {
  count      = var.vpc_config != null ? 1 : 0
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Optional: additional inline policies (e.g. DynamoDB, S3 access)
resource "aws_iam_role_policy" "extra" {
  count  = var.extra_policy_json != null ? 1 : 0
  name   = "${var.function_name}-extra-policy"
  role   = aws_iam_role.lambda.id
  policy = var.extra_policy_json
}
