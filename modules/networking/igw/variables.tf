variable "vpc_id" {
  description = "Provide VPC ID"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Map of common tags"
}
