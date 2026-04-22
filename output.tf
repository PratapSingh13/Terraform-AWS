# VPC
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The primary CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# Subnets
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.public_subnet.subnet_ids
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of public subnets"
  value       = module.public_subnet.subnet_cidr
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.private_subnet.subnet_ids
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of private subnets"
  value       = module.private_subnet.subnet_cidr
}

# Internet Gateway
output "igw_id" {
  description = "ID of the Internet Gateway"
  value       = module.igw.igw_id
}

# NAT Gateway
output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.nat_gateway.nat_gateway_id
}

# Route Tables
output "public_route_table_id" {
  description = "Public Route Table ID"
  value       = module.public_route_table.route_table_id
}

output "private_route_table_id" {
  description = "Private Route Table ID"
  value       = module.private_route_table.route_table_id
}

# Security Group
output "security_group_id" {
  description = "Value of the security group ID"
  value       = module.security_group.security_group_id
}

# VPC Peering
output "vpc_peering_ids" {
  description = "List of IDs of the VPC peering connections"
  value       = { for peering_name, peering_output in module.vpc_peering : peering_name => peering_output.vpc_peering_id }
}