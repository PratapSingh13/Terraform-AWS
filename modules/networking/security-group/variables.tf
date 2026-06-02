# ################################################################################
# Security Group
# ################################################################################
variable "create_security_group" {
  description = "Determines if a security group is created"
  type        = bool
}

variable "vpc_id" {
  description = "Identifier of the VPC where the security group will be created"
  type        = string
}

variable "security_group_name" {
  description = "Name to use on security group created"
  type        = string
}

variable "security_group_use_name_prefix" {
  description = "Determines whether the security group name (`security_group_name`) is used as a prefix"
  type        = bool
}

variable "security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = ""
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

variable "tags" {
  type        = map(string)
  description = "Map of common tags"
}

# ################################################################################
# # Local Variables
# ################################################################################
variable "create" {
  type        = bool
  default     = true
  description = "Controls if resources should be created (affects nearly all resources)"
}

variable "security_groups" {
  description = "A list of security group IDs to assign to the LB"
  type        = list(string)
  default     = []
}

