variable "zones" {
  type = map(object({
    name    = string
    vpc_ids = optional(list(string), [])
  }))
}

variable "records" {
  type = map(object({
    zone_key = string
    name     = string
    type     = string

    ttl     = optional(number)
    records = optional(list(string))

    alias = optional(object({
      name    = string
      zone_id = string
    }))

    set_identifier = optional(string)

    weight   = optional(number)
    failover = optional(string)
    region   = optional(string)

    geo = optional(object({
      continent = optional(string)
      country   = optional(string)
    }))

    geoproximity = optional(object({
      aws_region = optional(string)
      bias       = optional(number)
      coordinates = optional(object({
        latitude  = string
        longitude = string
      }))
    }))

    health_check_id = optional(string)
  }))
}

variable "health_checks" {
  type = map(object({
    fqdn          = string
    type          = string
    resource_path = optional(string)
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}