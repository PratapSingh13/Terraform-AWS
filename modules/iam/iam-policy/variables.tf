variable "policies" {
  description = "Map of IAM policies"
  type = map(object({
    name        = optional(string)
    description = string
    policy      = any
    tags        = optional(map(string))
  }))

  validation {
    condition     = length(var.policies) > 0
    error_message = "At least one IAM policy must be provided."
  }

  validation {
    condition = alltrue([
      for p in var.policies :
      length(trimspace(p.description)) > 0
    ])
    error_message = "Each policy must have a non-empty description."
  }

  validation {
    condition = alltrue([
      for p in var.policies :
      can(p.policy)
    ])
    error_message = "Each policy must have a policy document."
  }
}

variable "tags" {
  type        = map(string)
  description = "Map of common tags"
}