variable "vpc_id" {
  description = "Provide VPC ID"
  type        = string
}

variable "availability_zones" {
  description = "The az where resources will be deployed"
  type        = list(string)
}

variable "subnet_cidr" {
  description = "CIDR block for Subnet"
  type        = list(string)
}

variable "subnet_name" {
  description = "Name suffix for the subnets (e.g., public-subnet, private-subnet)"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Map of common tags"
}
