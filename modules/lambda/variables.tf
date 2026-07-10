# ─────────────────────────────────────────────
# Required
# ─────────────────────────────────────────────
variable "function_name" {
  description = "Unique name for the Lambda function."
  type        = string
}

# ─────────────────────────────────────────────
# Deployment package
# ─────────────────────────────────────────────
variable "package_type" {
  description = "Lambda deployment package type: 'Zip' or 'Image'."
  type        = string
  default     = "Zip"
  validation {
    condition     = contains(["Zip", "Image"], var.package_type)
    error_message = "package_type must be 'Zip' or 'Image'."
  }
}

variable "filename" {
  description = "Path to the local zip archive (required when package_type = Zip)."
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Base64-encoded SHA256 hash of the zip file for change detection."
  type        = string
  default     = null
}

variable "handler" {
  description = "Function entry point in 'file.method' notation (Zip only)."
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Lambda runtime identifier, e.g. python3.12, nodejs20.x (Zip only)."
  type        = string
  default     = "python3.12"
}

variable "image_uri" {
  description = "ECR image URI (required when package_type = Image)."
  type        = string
  default     = null
}

# ─────────────────────────────────────────────
# Function configuration
# ─────────────────────────────────────────────
variable "description" {
  description = "Human-readable description of the Lambda function."
  type        = string
  default     = ""
}

variable "memory_size" {
  description = "Memory allocated to the function in MB (128–10240)."
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Maximum execution time in seconds (1–900)."
  type        = number
  default     = 30
}

variable "reserved_concurrency" {
  description = "Reserved concurrent executions (-1 = unreserved, 0 = throttled)."
  type        = number
  default     = -1
}

variable "environment_variables" {
  description = "Map of environment variables to pass to the function."
  type        = map(string)
  default     = {}
}

variable "layer_arns" {
  description = "List of Lambda Layer ARNs to attach (max 5)."
  type        = list(string)
  default     = []
}

variable "tracing_mode" {
  description = "X-Ray tracing mode: 'PassThrough' or 'Active'."
  type        = string
  default     = "PassThrough"
}

# ─────────────────────────────────────────────
# Networking
# ─────────────────────────────────────────────
variable "vpc_config" {
  description = "VPC configuration block. Set to null to run outside a VPC."
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

# ─────────────────────────────────────────────
# Reliability / resilience
# ─────────────────────────────────────────────
variable "dead_letter_arn" {
  description = "ARN of an SQS queue or SNS topic to receive failed-invocation payloads."
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 14
}

# ─────────────────────────────────────────────
# IAM extensions
# ─────────────────────────────────────────────
variable "extra_policy_json" {
  description = "Optional inline IAM policy JSON granting additional permissions."
  type        = string
  default     = null
}

# ─────────────────────────────────────────────
# Aliases
# ─────────────────────────────────────────────
variable "aliases" {
  description = <<-EOT
    Map of Lambda aliases to create.
    Each entry accepts:
      function_version           - "$LATEST" or a published version number
      additional_version_weights - optional canary routing map
  EOT
  type = map(object({
    function_version           = string
    additional_version_weights = optional(map(number))
  }))
  default = {}
}

# ─────────────────────────────────────────────
# Event source mappings
# ─────────────────────────────────────────────
variable "event_source_mappings" {
  description = <<-EOT
    Map of event source mappings (SQS, DynamoDB Streams, Kinesis).
    Keys are logical names; values are:
      event_source_arn, batch_size, starting_position (streams only),
      enabled, bisect_batch_on_error, batching_window_seconds
  EOT
  type        = map(any)
  default     = {}
}

# ─────────────────────────────────────────────
# Triggers / resource-based policy
# ─────────────────────────────────────────────
variable "allowed_triggers" {
  description = <<-EOT
    Map of resource-based policy statements that allow other services to invoke
    this function. Each entry:
      principal  - AWS service principal (e.g. apigateway.amazonaws.com)
      source_arn - (optional) restrict to a specific resource ARN
      qualifier  - (optional) alias or version qualifier
  EOT
  type        = map(any)
  default     = {}
}

# ─────────────────────────────────────────────
# Tagging
# ─────────────────────────────────────────────
variable "tags" {
  description = "Resource tags to apply to all created resources."
  type        = map(string)
  default     = {}
}
