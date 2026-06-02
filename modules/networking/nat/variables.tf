variable "public_subnet_ids" {
  description = "List of public subnet IDs for NAT gateway placement"
  type        = list(string)
}

variable "tags" {
  type        = map(string)
  description = "Map of common tags"
}
