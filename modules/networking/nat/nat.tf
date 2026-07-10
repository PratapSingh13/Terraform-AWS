/*
──────────────────────────────────────────────────────────────────────
NAT Gateway (NAT) Module – Networking
──────────────────────────────────────────────────────────────────────
📌 Purpose: Provide outbound internet access for private subnets by
            attaching NAT on a public subnet.
📅 Created: 14‑01‑2026
👤 Owner:   Yogendra Pratap Singh (yogendra.singh01@nagarro.com)
🏢 Team:    Infrastructure / DevOps
💰 Cost Center: 12345‑AWS‑NAT
🌍 Region: ${var.aws_region}
🗂️ Components:
  - aws_nat_gateway "nat"
🔗 References:
  – AWS NAT Gateway docs: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html
  – Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway
🔐 Security / Compliance:
  - NAT is a shared, public‑facing resource – ensure only intended
    private subnets are associated via route tables.
  - Tags include `project` and `environment` for cost allocation and
    auditability.
📦 Inputs (variables) – see variables.tf:
  - vpc_id      – ID of the VPC to which the IGW will be attached.
  - project     – Project name (used for tagging).
  - environment – Deployment environment (dev, staging, prod, …).
📤 Outputs – see output.tf:
  - nat_id – ID of the created NAT Gateway.
──────────────────────────────────────────────────────────────────────

──────────────────────────────────────────────────────────────────────
aws_nat_gateway "nat"
──────────────────────────────────────────────────────────────────────
Creates an NAT Gateway and attaches it to the VPC supplied via
var.vpc_id. The resource is tagged with the project and environment
for easy identification in the AWS console and for cost‑allocation.
*/

# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  vpc = true

  tags = merge(
    var.tags,
    {
      Name        = "eip-${var.tags.Project}-${var.tags.Environment}"
      Environment = var.tags.Environment
    }
  )
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = var.public_subnet_ids[0]
  tags = merge(
    var.tags,
    {
      Name        = "${var.tags.Project}-${var.tags.Environment}-nat"
      Environment = var.tags.Environment
    }
  )
}
