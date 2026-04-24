#Variables for Public Route Table
variable "vpc_id" {
  description = "Provide VPC ID"
  type        = string
}

variable "nat_gateway_id" {
  description = "NAT Gateway ID for the VPC"
  type        = string
  default     = ""
}

variable "private_subnets_ids" {
  description = "IDs for private subnets"
  type        = list(string)
  default     = []
}

variable "vpc_peering_id" {
  description = "The ID of the VPC peering connection"
  type        = string
  default     = null
}

variable "destination_vpc_cidr" {
  description = "CIDR block of the peered VPC"
  type        = string
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Map of common tags"
}

variable "peering_routes" {
  description = "Map of VPC peering routes"
  type = map(object({
    peering_id = string
    cidr_block = string
  }))
  default = {}
}

variable "create_peering_route" {
  description = "Determines if a VPC peering route is created"
  type        = bool
  default     = false
}
