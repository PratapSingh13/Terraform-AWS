# ################################################################################
# VPC Peering Connection
# ################################################################################

variable "origin_vpc_id" {
  description = "The ID of the requester VPC"
  type        = string
  default     = null
}

variable "destination_vpc_owner_id" {
  description = "The ID of the owner of the accepter VPC"
  type        = string
  default     = null
}

variable "destination_vpc_id" {
  description = "The ID of the accepter VPC to peer with"
  type        = string
  default     = null
}

# variable "destination_vpc_region" {
#   description = "The region of the accepter VPC"
#   type        = string
#   default     = null
# }

variable "allow_remote_vpc_dns_resolution_accepter" {
  description = "Allow the accepter VPC to resolve DNS hostnames to private IP addresses when queried from instances in the requester VPC"
  type        = bool
  default     = true
}

variable "allow_remote_vpc_dns_resolution_requester" {
  description = "Allow the requester VPC to resolve DNS hostnames to private IP addresses when queried from instances in the accepter VPC"
  type        = bool
  default     = true
}

variable "auto_accept" {
  description = "Whether to accept the peering connection automatically (only works if both VPCs are in the same account and same region)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Map of common tags"
  type        = map(string)
}
