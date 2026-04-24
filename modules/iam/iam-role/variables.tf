variable "roles" {
  type = map(object({
    assume_role_policy = any
  }))
}
