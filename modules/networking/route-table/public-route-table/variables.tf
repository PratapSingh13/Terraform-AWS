#Variables for Public Route Table
variable "vpc_id" {
  description = "Provide VPC ID"
  type        = string
}

variable "igw_id" {
  description = "Internet Gateway ID for the VPC"
  type        = string
  default     = ""
}

variable "public_subnets_cidr" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Map of common tags"
}
