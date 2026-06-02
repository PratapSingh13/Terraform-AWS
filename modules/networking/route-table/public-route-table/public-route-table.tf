/*
───────────────────────────────────────────────────────────────────────
aws_route_table "public-route-table"
───────────────────────────────────────────────────────────────────────
📌 Purpose:  Define a route table for public subnets that routes all
             outbound traffic (0.0.0.0/0) through the Internet Gateway.
📅 Created: 14‑01‑2026
👤 Owner:  Yogendra Pratap Singh (yogendra.singh01@nagarro.com)
🏢 Team:    Infrastructure / DevOps
🌍 Region:  ${var.aws_region}
🗂️ Components:
  • aws_route_table "public-route-table"
  • aws_route_table_association for each public subnet
🔗 References:
  – AWS Route Table docs: https://docs.aws.amazon.com/vpc/latest/userguide/route-tables.html
  – Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
🔐 Security / Compliance:
  • Default route (0.0.0.0/0) points to the Internet Gateway –
    ensure only intended subnets are associated.
  • Tags include `project`, `environment` for cost allocation.
📦 Inputs (variables) – see variables.tf:
  • vpc_id – ID of the VPC to attach the route table.
  • igw_id – ID of the Internet Gateway for the default route.
  • project, environment – tagging metadata.
  • public_subnets_cidr – List of CIDR blocks (or subnet IDs) for
    public subnets; each entry creates an association.
📤 Outputs – see output.tf:
  • public_route_table_id – ID of the created route table.
  • public_route_table_association_ids – Map of subnet ID → association ID.
───────────────────────────────────────────────────────────────────────
Creates a route table attached to the VPC that forwards all traffic
(0.0.0.0/0) to the Internet Gateway (`var.igw_id`).
Tags are applied for identification and cost tracking.
*/

resource "aws_route_table" "public-route-table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.tags.Project}-${var.tags.Environment}-public-route-table"
      Environment = var.tags.Environment
    }
  )
}

/*
---------------------------------------------------------------------
aws_route_table_association "public"
---------------------------------------------------------------------
Associates the above route table with each public subnet. The `for_each`
iterates over `var.public_subnets_ids` (expected to be a list of
subnet IDs or CIDR strings that map to subnet IDs). Adjust the variable
type if you prefer to pass explicit subnet IDs.
*/

resource "aws_route_table_association" "public" {
  for_each       = { for idx, subnet_id in var.public_subnets_ids : idx => subnet_id }
  subnet_id      = each.value
  route_table_id = aws_route_table.public-route-table.id
}
