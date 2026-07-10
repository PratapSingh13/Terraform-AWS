/*
──────────────────────────────────────────────────────────────────────
Internet Gateway (IGW) Module – Networking
──────────────────────────────────────────────────────────────────────
📌 Purpose: Provide outbound internet access for public subnets by
            attaching an Internet Gateway to the VPC.
📅 Created: 14‑01‑2026
👤 Owner:   Yogendra Pratap Singh (yogendra.singh01@nagarro.com)
🏢 Team:    Infrastructure / DevOps
💰 Cost Center: 12345‑AWS‑IGW
🌍 Region: ${var.aws_region}
🗂️ Components:
  - aws_internet_gateway "igw"
🔗 References:
  – AWS Internet Gateway docs: https://docs.aws.amazon.com/vpc/latest/userguide/igw.html
  – Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
🔐 Security / Compliance:
  - IGW is a shared, public‑facing resource – ensure only intended
    public subnets are associated via route tables.
  - Tags include `project` and `environment` for cost allocation and
    auditability.
📦 Inputs (variables) – see variables.tf:
  - vpc_id      – ID of the VPC to which the IGW will be attached.
  - project     – Project name (used for tagging).
  - environment – Deployment environment (dev, staging, prod, …).
📤 Outputs – see output.tf:
  - igw_id – ID of the created Internet Gateway.
──────────────────────────────────────────────────────────────────────

──────────────────────────────────────────────────────────────────────
aws_internet_gateway "igw"
──────────────────────────────────────────────────────────────────────
Creates an Internet Gateway and attaches it to the VPC supplied via
var.vpc_id. The resource is tagged with the project and environment
for easy identification in the AWS console and for cost‑allocation.
*/

resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name        = "${var.tags.Project}-${var.tags.Environment}-igw"
      Environment = var.tags.Environment
    }
  )
}
