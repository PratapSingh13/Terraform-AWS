variable "users" {
  description = "Map of IAM users to create."
  type = map(object({
    console_access  = bool
    pgp_key         = optional(string)
    password_length = optional(number, 20)
    password        = optional(string)
    tags            = map(string)
  }))
}
