# ################################################################################
# Global Variables
# ################################################################################
variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "project" {
  description = "The name of the project"
  type        = string
}

variable "owner" {
  description = "The owner of the project"
  type        = string
}

variable "managed_by" {
  description = "The entity that manages the utility (Terraform, Ansible, etc.)"
  type        = string
}

variable "environment" {
  description = "The environment of the project"
  type        = string
}

# ################################################################################
# Variables for VPC
# ################################################################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# ################################################################################
# Variables for Subnets
# ################################################################################

variable "public_subnets_cidr" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

# ################################################################################
# Security Group
# ################################################################################
variable "create_security_group" {
  description = "Determines if a security group is created"
  type        = bool
}

variable "security_group_use_name_prefix" {
  description = "Determines whether the security group name (`security_group_name`) is used as a prefix"
  type        = bool
}

variable "security_group_tags" {
  description = "A map of additional tags to add to the security group created"
  type        = map(string)
  default     = {}
}

variable "security_group_egress_rules" {
  description = "Security group egress rules to add to the security group created"
  type = map(object({
    ip_protocol = optional(string) # protocol like tcp, udp, -1 (all)
    from_port   = optional(number) # starting port
    to_port     = optional(number) # ending port
    cidr_ipv4   = optional(string) # destination CIDR
  }))
  default = {}
}

variable "security_group_ingress_rules" {
  description = "Security group ingress rules to add to the security group created"
  type = map(object({
    ip_protocol = optional(string)
    from_port   = number
    to_port     = number
    cidr_ipv4   = string
  }))
  default = {}
}

# ################################################################################
# Network ACL
# ################################################################################

variable "nacls" {
  description = "Map of NACL configurations"
  type = map(object({
    subnet_ids = optional(list(string), [])
    ingress = optional(list(object({
      rule_number = number
      protocol    = string
      action      = string
      cidr_block  = string
      from_port   = number
      to_port     = number
    })), [])
    egress = optional(list(object({
      rule_number = number
      protocol    = string
      action      = string
      cidr_block  = string
      from_port   = number
      to_port     = number
    })), [])
    tags = optional(map(string), {})
  }))
}

# ################################################################################
# Variables for VPC Peering
# ################################################################################
variable "enable_vpc_peering" {
  description = "Determines if VPC peering connections are created"
  type        = bool
  default     = false
}

variable "vpc_peerings" {
  description = "Map of VPC peering configurations"
  type = map(object({
    peer_owner_id                             = string
    peer_vpc_id                               = string
    peer_region                               = string
    destination_vpc_cidr                      = string
    allow_remote_vpc_dns_resolution_accepter  = optional(bool, true)
    allow_remote_vpc_dns_resolution_requester = optional(bool, true)
  }))
  default = {}
}

# ################################################################################
# IAM Users
# ################################################################################
variable "users" {
  description = "Map of IAM users to create."
  type = map(object({
    console_access  = bool
    pgp_key         = optional(string)
    password_length = optional(number, 20)
    password        = optional(string)
    tags            = optional(map(string), {})
  }))
}

# ################################################################################
# IAM Policies
# ################################################################################
variable "policies" {
  description = "IAM policies configuration"

  type = map(object({
    name        = optional(string)
    description = string
    policy      = any
    path        = optional(string)
    tags        = optional(map(string))
  }))
}

# ################################################################################
# IAM Roles
# ################################################################################
variable "roles" {
  description = "IAM roles configuration"

  type = map(object({
    name                 = optional(string)
    description          = optional(string)
    assume_role_policy   = any
    path                 = optional(string)
    max_session_duration = optional(number)
    tags                 = optional(map(string))
  }))
}

# ################################################################################
# Route53
# ################################################################################
# ################################################################################
# Route53
# ################################################################################

variable "default_vpc_ids" {
  description = "Fallback VPC IDs if not provided in zones"
  type        = list(string)
  default     = []
}

variable "zones" {
  type = map(object({
    name    = string
    vpc_ids = optional(list(string), [])
  }))
}

variable "records" {
  description = "Route53 DNS records"

  type = map(object({
    zone_key = string
    name     = string
    type     = string

    ttl     = optional(number)
    records = optional(list(string))

    alias = optional(object({
      name    = string
      zone_id = string
    }))

    set_identifier = optional(string)

    weight   = optional(number)
    failover = optional(string)
    region   = optional(string)

    # ✅ GEO
    geo = optional(object({
      country   = optional(string)
      continent = optional(string)
    }))

    # ✅ GEOPROXIMITY
    geoproximity = optional(object({
      aws_region = optional(string)
      bias       = optional(number)
      coordinates = optional(object({
        latitude  = string
        longitude = string
      }))
    }))

    health_check_id = optional(string)
  }))
}

variable "health_checks" {
  type = map(object({
    fqdn          = string
    type          = string
    resource_path = optional(string)
  }))
}
