variable "role_attachments" {
  description = "Map of role to list of policy keys"
  type        = map(list(string))
  default     = {}
}

variable "user_attachments" {
  description = "Map of user to list of policy keys"
  type        = map(list(string))
  default     = {}
}

variable "policy_arns" {
  description = "Map of policy keys to ARNs"
  type        = map(string)
}

variable "group_attachments" {
  type    = map(list(string))
  default = {}
}