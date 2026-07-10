/*
──────────────────────────────────────────────────────────────────────
Terraform VPC Module – Networking
──────────────────────────────────────────────────────────────────────
📌 Purpose:     Create a reusable AWS VPC for the <PROJECT‑NAME> environment.
📅 Created:     20-04-2026
👤 Owner:       Yogendra Pratap Singh (yogendra.singh01@nagarro.com)
🏢 Team:        Infrastructure / DevOps
💰 Cost Center: 12345‑AWS‑VPC
🌍 Region**:    ${var.aws_region}
📦 CIDR Block:  ${var.vpc_cidr}
🗂️ Components:
  - VPC
  - Internet Gateway
  - Public & Private Subnets (per AZ)
  - Route Tables & Associations
  - NAT Gateways (optional)
  - VPC Flow Logs (optional)
📚 References:
  – Architecture diagram: https://example.com/diagrams/vpc‑architecture.png
  – AWS VPC best‑practice guide: https://docs.aws.amazon.com/vpc/latest/userguide/
  – Terraform AWS Provider docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
🔐 Security / Compliance:
  - No public IPs on private subnets
  - Flow logs sent to CloudWatch Log Group ${var.flow_log_group}
  - Tags include environment, owner, project, cost_center
🛠️ Inputs (variables) – see variables.tf:
  - vpc_cidr – CIDR block for the VPC (e.g. 10.0.0.0/16)
  - public_subnet_cidrs – List of CIDRs for public subnets (one per AZ)
  - private_subnet_cidrs – List of CIDRs for private subnets (one per AZ)
  - enable_nat_gateway – Boolean to provision NAT gateways
  - tags – Map of common tags applied to all resources
📤 Outputs (see outputs.tf):
  - vpc_id
*/

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.tags.Project}-${var.tags.Environment}-vpc"
      Environment = var.tags.Environment
    }
  )
}
