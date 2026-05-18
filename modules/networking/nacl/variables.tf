variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Map of common tags"
  default     = {}
}

variable "nacls" {
  description = "Map of NACL configurations"

  type = map(object({
    subnet_ids = optional(list(string), [])
    subnet_keys = optional(list(string), [])

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

  # validation {
  #   condition = alltrue([
  #     for k, v in var.nacls :
  #     (
  #       length(v.subnet_ids) > 0 ||
  #       length(v.subnet_keys) > 0
  #     )
  #   ])
  #   error_message = "Each NACL must define at least one of subnet_ids or subnet_keys."
  # }
}

variable "subnet_map" {
  description = "Map of subnet groups (e.g., public/private)"
  type        = map(list(string))
  default     = {}
}