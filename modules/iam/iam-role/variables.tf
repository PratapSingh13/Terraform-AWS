variable "roles" {
  description = "Map of IAM roles"

  type = map(object({
    name                 = optional(string)
    description          = optional(string)
    assume_role_policy   = any
    path                 = optional(string)
    max_session_duration = optional(number)
    tags                 = optional(map(string))
  }))

  # ✅ Validation
  validation {
    condition     = length(var.roles) > 0
    error_message = "At least one IAM role must be defined."
  }

  validation {
    condition = alltrue([
      for r in var.roles :
      can(r.assume_role_policy.Version)
    ])
    error_message = "Each role must include a valid assume_role_policy with Version."
  }
}

variable "tags" {
  type        = map(string)
  description = "Map of common tags"
}
