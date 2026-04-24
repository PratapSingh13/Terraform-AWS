variable "role_policy_attachments" {
  type = map(object({
    role       = string
    policy_arn = string
  }))
  default = {}
}

variable "user_policy_attachments" {
  type = map(object({
    user       = string
    policy_arn = string
  }))
  default = {}
}
