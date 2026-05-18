# VPC
# output "vpc_id" {
#   description = "ID of the VPC"
#   value       = module.vpc.vpc_id
# }

# output "vpc_cidr" {
#   description = "The primary CIDR block of the VPC"
#   value       = module.vpc.vpc_cidr_block
# }

# output "tags" {
#   value = module.vpc.tags
# }

# # Subnets
# output "public_subnet_ids" {
#   description = "List of public subnet IDs"
#   value       = module.public_subnet.subnet_ids
# }

# output "public_subnet_cidrs" {
#   description = "CIDR blocks of public subnets"
#   value       = module.public_subnet.subnet_cidr
# }

# output "private_subnet_ids" {
#   description = "List of private subnet IDs"
#   value       = module.private_subnet.subnet_ids
# }

# output "private_subnet_cidrs" {
#   description = "CIDR blocks of private subnets"
#   value       = module.private_subnet.subnet_cidr
# }

# # Internet Gateway
# output "igw_id" {
#   description = "ID of the Internet Gateway"
#   value       = module.igw.igw_id
# }

# # NAT Gateway
# output "nat_gateway_id" {
#   description = "NAT Gateway ID"
#   value       = module.nat_gateway.nat_gateway_id
# }

# # Route Tables
# output "public_route_table_id" {
#   description = "Public Route Table ID"
#   value       = module.public_route_table.route_table_id
# }

# output "private_route_table_id" {
#   description = "Private Route Table ID"
#   value       = module.private_route_table.route_table_id
# }

# # Security Group
# output "security_group_id" {
#   description = "Value of the security group ID"
#   value       = module.security_group.security_group_id
# }

# # VPC Peering
# output "vpc_peering_ids" {
#   description = "List of IDs of the VPC peering connections"
#   value       = { for peering_name, peering_output in module.vpc_peering : peering_name => peering_output.vpc_peering_id }
# }


# IAM User
# output "user_arns" {
#   description = "All created IAM user ARNs."
#   value       = module.iam_user.user_arns
# }

# output "user_names" {
#   description = "All created IAM user names."
#   value       = module.iam_user.user_names
# }

# output "console_access_users" {
#   description = "Users with console access enabled."
#   value       = module.iam_user.console_access_users
# }

# output "encrypted_passwords" {
#   description = "Encrypted passwords — decrypt with your PGP private key."
#   value       = module.iam_user.encrypted_passwords
#   sensitive   = true
# }

# # IAM Policy
# output "iam_policy_arns" {
#   description = "Map of IAM policy ARNs"
#   value       = module.iam_policy.policy_arns
# }
# output "iam_policy_names" {
#   description = "Map of IAM policy names"
#   value       = keys(module.iam_policy.policy_arns)
# }

# # IAM Role
# output "iam_role_arns" {
#   description = "Map of IAM role ARNs"
#   value       = module.iam_role.role_arns
# }

# output "iam_role_names" {
#   description = "Map of IAM role names"
#   value       = module.iam_role.role_names
# }

# output "iam_role_ids" {
#   description = "Map of IAM role IDs"
#   value       = module.iam_role.role_ids
# }

################################################################################
# API Gateway (from module.api)
################################################################################

# output "api_id" {
#   description = "API Gateway ID"
#   value       = module.api.api_id
# }

# output "api_arn" {
#   description = "API Gateway ARN"
#   value       = module.api.api_arn
# }

# output "api_endpoint" {
#   description = "API endpoint"
#   value       = module.api.api_endpoint
# }

# output "api_execution_arn" {
#   description = "Execution ARN (used for Lambda permissions)"
#   value       = module.api.execution_arn
# }

# ################################################################################
# # Stage
# ################################################################################

# output "api_stage_name" {
#   description = "API stage name"
#   value       = module.api.stage_name
# }

# output "api_invoke_url" {
#   description = "Full invoke URL"
#   value       = module.api.invoke_url
# }

# ################################################################################
# # Integrations & Routes
# ################################################################################

# output "api_integrations" {
#   description = "Map of integration IDs"
#   value       = module.api.integration_ids
# }

# output "api_routes" {
#   description = "Map of route IDs"
#   value       = module.api.route_ids
# }

# ################################################################################
# # Authorizers
# ################################################################################

# output "api_authorizers" {
#   description = "Map of authorizer IDs"
#   value       = module.api.authorizer_ids
# }

# ################################################################################
# # Custom Domain (Optional)
# ################################################################################

# output "api_domain_name" {
#   description = "Custom domain name"
#   value       = module.api.domain_name
# }

# output "api_domain_target" {
#   description = "Domain target (for Route53 alias)"
#   value       = module.api.domain_target
# }

# output "api_domain_hosted_zone_id" {
#   description = "Hosted zone ID for alias"
#   value       = module.api.domain_hosted_zone_id
# }