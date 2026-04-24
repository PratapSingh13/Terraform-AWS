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