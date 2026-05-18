variable "name" {
  type = string
}

variable "protocol_type" {
  type    = string
  default = "HTTP"
}

variable "cors_configuration" {
  type = object({
    allow_origins = list(string)
    allow_methods = list(string)
    allow_headers = list(string)
  })
  default = null
}

variable "authorizers" {
  type = map(object({
    authorizer_type  = string # JWT / REQUEST
    identity_sources = list(string)

    jwt_configuration = optional(object({
      audience = list(string)
      issuer   = string
    }))
  }))
  default = {}
}

variable "integrations" {
  type = map(object({
    integration_type       = string # AWS_PROXY / HTTP_PROXY
    integration_uri        = string
    payload_format_version = optional(string, "2.0")
    timeout_milliseconds   = optional(number, 30000)
  }))
}

variable "routes" {
  type = map(object({
    route_key       = string
    integration_key = string
    authorizer_key  = optional(string)
  }))
}

variable "stage" {
  type = object({
    name        = string
    auto_deploy = optional(bool, true)

    throttling = optional(object({
      burst_limit = number
      rate_limit  = number
    }))
  })
}

variable "domain" {
  type = object({
    domain_name     = string
    certificate_arn = string
  })
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
