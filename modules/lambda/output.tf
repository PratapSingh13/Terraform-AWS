output "function_arn" {
  description = "ARN of the Lambda function."
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Name of the Lambda function."
  value       = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  description = "ARN used to invoke the function via API Gateway."
  value       = aws_lambda_function.this.invoke_arn
}

output "qualified_arn" {
  description = "ARN including the function version."
  value       = aws_lambda_function.this.qualified_arn
}

output "version" {
  description = "Latest published version number."
  value       = aws_lambda_function.this.version
}

output "role_arn" {
  description = "ARN of the IAM execution role."
  value       = aws_iam_role.lambda.arn
}

output "role_name" {
  description = "Name of the IAM execution role."
  value       = aws_iam_role.lambda.name
}

output "log_group_name" {
  description = "CloudWatch log group name."
  value       = aws_cloudwatch_log_group.lambda.name
}

output "alias_arns" {
  description = "Map of alias name → ARN."
  value       = { for k, v in aws_lambda_alias.this : k => v.arn }
}
