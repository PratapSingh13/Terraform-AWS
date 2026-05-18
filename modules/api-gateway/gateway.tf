################################################################################
# API Gateway
################################################################################
resource "aws_apigatewayv2_api" "this" {
  name          = var.name
  protocol_type = var.protocol_type

  dynamic "cors_configuration" {
    for_each = var.cors_configuration != null ? [var.cors_configuration] : []
    content {
      allow_origins = cors_configuration.value.allow_origins
      allow_methods = cors_configuration.value.allow_methods
      allow_headers = cors_configuration.value.allow_headers
    }
  }

  tags = var.tags
}

################################################################################
# API Gateway Authorizers
################################################################################
resource "aws_apigatewayv2_authorizer" "this" {
  for_each = var.authorizers

  api_id = aws_apigatewayv2_api.this.id
  name   = each.key

  authorizer_type  = each.value.authorizer_type
  identity_sources = each.value.identity_sources

  dynamic "jwt_configuration" {
    for_each = lookup(each.value, "jwt_configuration", null) != null ? [1] : []
    content {
      audience = each.value.jwt_configuration.audience
      issuer   = each.value.jwt_configuration.issuer
    }
  }
}

################################################################################
# API Gateway Integration
################################################################################
resource "aws_apigatewayv2_integration" "this" {
  for_each = var.integrations

  api_id = aws_apigatewayv2_api.this.id

  integration_type       = each.value.integration_type
  integration_uri        = each.value.integration_uri
  payload_format_version = lookup(each.value, "payload_format_version", "2.0")
  timeout_milliseconds   = lookup(each.value, "timeout_milliseconds", 30000)
}

################################################################################
# API Gateway Route
################################################################################
resource "aws_apigatewayv2_route" "this" {
  for_each = var.routes

  api_id    = aws_apigatewayv2_api.this.id
  route_key = each.value.route_key

  target = "integrations/${aws_apigatewayv2_integration.this[each.value.integration_key].id}"

  authorizer_id = lookup(each.value, "authorizer_key", null) != null ? aws_apigatewayv2_authorizer.this[each.value.authorizer_key].id : null
}

################################################################################
# API Gateway Stage
################################################################################
resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage.name
  auto_deploy = lookup(var.stage, "auto_deploy", true)

  dynamic "default_route_settings" {
    for_each = lookup(var.stage, "throttling", null) != null ? [1] : []
    content {
      throttling_burst_limit = var.stage.throttling.burst_limit
      throttling_rate_limit  = var.stage.throttling.rate_limit
    }
  }

  tags = var.tags
}

################################################################################
# API Gateway Custom Domain Name
################################################################################
resource "aws_apigatewayv2_domain_name" "this" {
  count = var.domain != null ? 1 : 0

  domain_name = var.domain.domain_name

  domain_name_configuration {
    certificate_arn = var.domain.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

################################################################################
# API Gateway Mapping
################################################################################
resource "aws_apigatewayv2_api_mapping" "this" {
  count = var.domain != null ? 1 : 0

  api_id      = aws_apigatewayv2_api.this.id
  domain_name = aws_apigatewayv2_domain_name.this[0].domain_name
  stage       = aws_apigatewayv2_stage.this.name
}
