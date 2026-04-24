locals {

  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]

  common_tags = {
    Project    = var.project
    Owner      = var.owner
    managed_by = var.managed_by
  }

  env_tags = {
    Environment = var.environment
  }

  # Flatten peerings for route table consumption
  peering_routes = merge([
    for peer_key, peer_config in var.vpc_peerings : {
      (peer_key) = {
        peering_id = try(module.vpc_peering[peer_key].vpc_peering_id, null)
        cidr_block = peer_config.destination_vpc_cidr
      }
    }
  ]...)
}

module "vpc" {
  source = "./modules/networking/vpc"

  vpc_cidr = var.vpc_cidr
  tags = merge(
    local.common_tags,
    local.env_tags
  )
}

module "public_subnet" {
  source = "./modules/networking/subnet"

  vpc_id             = module.vpc.vpc_id
  availability_zones = local.availability_zones
  subnet_cidr        = var.public_subnets_cidr
  subnet_name        = "public-subnet"
  tags = merge(
    local.common_tags,
    local.env_tags
  )

  depends_on = [module.vpc]
}

module "private_subnet" {
  source = "./modules/networking/subnet"

  vpc_id             = module.vpc.vpc_id
  availability_zones = local.availability_zones
  subnet_cidr        = var.private_subnets_cidr
  subnet_name        = "private-subnet"
  tags = merge(
    local.common_tags,
    local.env_tags
  )

  depends_on = [module.vpc]
}

module "igw" {
  source = "./modules/networking/igw"

  vpc_id = module.vpc.vpc_id
  tags = merge(
    local.common_tags,
    local.env_tags
  )

  depends_on = [module.vpc]
}

module "nat_gateway" {
  source = "./modules/networking/nat"

  public_subnet_ids = module.public_subnet.subnet_ids
  tags = merge(
    local.common_tags,
    local.env_tags
  )

  depends_on = [module.public_subnet]
}

module "public_route_table" {
  source = "./modules/networking/route-table/public-route-table"

  vpc_id             = module.vpc.vpc_id
  igw_id             = module.igw.igw_id
  public_subnets_ids = module.public_subnet.subnet_ids
  tags = merge(
    local.common_tags,
    local.env_tags
  )

  depends_on = [module.public_subnet, module.igw]
}

module "private_route_table" {
  source = "./modules/networking/route-table/private-route-table"

  vpc_id              = module.vpc.vpc_id
  nat_gateway_id      = module.nat_gateway.nat_gateway_id
  private_subnets_ids = module.private_subnet.subnet_ids

  peering_routes = var.enable_vpc_peering ? {
    for peering_name, peering_config in var.vpc_peerings : peering_name => {
      peering_id = module.vpc_peering[peering_name].vpc_peering_id
      cidr_block = peering_config.destination_vpc_cidr
    }
  } : {}

  tags = merge(
    local.common_tags,
    local.env_tags
  )

  depends_on = [module.private_subnet, module.igw, module.vpc_peering]
}

module "security_group" {
  source = "./modules/networking/security-group"

  create_security_group          = var.create_security_group
  vpc_id                         = module.vpc.vpc_id
  security_group_name            = "${local.common_tags.Project}-${local.env_tags.Environment}-sg"
  security_group_use_name_prefix = var.security_group_use_name_prefix
  security_group_description     = "This security group belongs to general applications in the ${var.environment}-${var.project} environment"
  security_group_tags            = var.security_group_tags
  security_group_ingress_rules   = var.security_group_ingress_rules
  security_group_egress_rules    = var.security_group_egress_rules

  tags = merge(
    local.common_tags,
    local.env_tags,
    { terraform-aws-modules = "sg" }
  )

  depends_on = [module.vpc]
}

module "vpc_peering" {
  for_each = var.enable_vpc_peering ? var.vpc_peerings : {}

  source = "./modules/networking/vpc-peering"

  origin_vpc_id            = module.vpc.vpc_id
  destination_vpc_owner_id = each.value.peer_owner_id
  destination_vpc_id       = each.value.peer_vpc_id
  # destination_vpc_region                  = each.value.peer_region
  allow_remote_vpc_dns_resolution_accepter  = each.value.allow_remote_vpc_dns_resolution_accepter
  allow_remote_vpc_dns_resolution_requester = each.value.allow_remote_vpc_dns_resolution_requester

  tags = merge(
    local.common_tags,
    local.env_tags,
    { Name = "peering-${each.key}" }
  )

  depends_on = [module.vpc]
}

module "iam_user" {
  source = "./modules/iam/iam-user"

  users = {
    for user_name, user_config in var.users : user_name => {
      console_access  = user_config.console_access
      pgp_key         = user_config.pgp_key
      password_length = user_config.password_length
      password        = user_config.password
      tags = merge(
        local.common_tags,
        local.env_tags,
        user_config.tags
      )
    }
  }
}

module "iam_policy" {
  source = "./modules/iam/iam-policy"

  tags = merge(
    local.common_tags,
    local.env_tags
  )
  policies = var.policies
}
