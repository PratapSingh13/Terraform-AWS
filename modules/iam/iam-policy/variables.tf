variable "policies" {
  description = "Map of IAM policies"
  type = map(object({
    description = string
    policy      = any
  }))
}
