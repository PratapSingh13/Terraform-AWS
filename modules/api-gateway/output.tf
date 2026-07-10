################################################################################
# API
################################################################################
output "api_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.this.id
}

output "api_arn" {
  description = "API Gateway ARN"
  value       = aws_apigatewayv2_api.this.arn
}

output "api_endpoint" {
  description = "API endpoint URL"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "execution_arn" {
  description = "Execution ARN for Lambda permissions"
  value       = aws_apigatewayv2_api.this.execution_arn
}

################################################################################
# Stage
################################################################################
output "stage_name" {
  description = "Stage name"
  value       = aws_apigatewayv2_stage.this.name
}

output "stage_arn" {
  description = "Stage ARN"
  value       = aws_apigatewayv2_stage.this.arn
}

output "invoke_url" {
  description = "Invoke URL (full URL with stage)"
  value       = aws_apigatewayv2_stage.this.invoke_url
}

################################################################################
# Integrations
################################################################################
output "integration_ids" {
  description = "Map of integration IDs"
  value = {
    for k, v in aws_apigatewayv2_integration.this :
    k => v.id
  }
}

################################################################################
# Routes
################################################################################
output "route_ids" {
  description = "Map of route IDs"
  value = {
    for k, v in aws_apigatewayv2_route.this :
    k => v.id
  }
}

################################################################################
# Authorizers
################################################################################
output "authorizer_ids" {
  description = "Map of authorizer IDs"
  value = {
    for k, v in aws_apigatewayv2_authorizer.this :
    k => v.id
  }
}

################################################################################
# Custom Domain (Optional)
################################################################################
output "domain_name" {
  description = "Custom domain name"
  value       = try(aws_apigatewayv2_domain_name.this[0].domain_name, null)
}

output "domain_target" {
  description = "Domain target (for Route53 alias)"
  value       = try(aws_apigatewayv2_domain_name.this[0].domain_name_configuration[0].target_domain_name, null)
}

output "domain_hosted_zone_id" {
  description = "Hosted zone ID for Route53 alias"
  value       = try(aws_apigatewayv2_domain_name.this[0].domain_name_configuration[0].hosted_zone_id, null)
}