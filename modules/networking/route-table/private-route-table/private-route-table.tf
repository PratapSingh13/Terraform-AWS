/*
───────────────────────────────────────────────────────────────────────
aws_route_table "private-route-table"
───────────────────────────────────────────────────────────────────────
📌 Purpose:  Define a route table for private subnets that routes all
             outbound traffic (0.0.0.0/0) through the Internet Gateway.
📅 Created: 14‑01‑2026
👤 Owner:  Yogendra Pratap Singh (yogendra.singh01@nagarro.com)
🏢 Team:    Infrastructure / DevOps
🌍 Region:  ${var.aws_region}
🗂️ Components:
  • aws_route_table "private-route-table"
  • aws_route_table_association for each private subnet
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
  • private_subnets_cidr – List of CIDR blocks (or subnet IDs) for
    private subnets; each entry creates an association.
📤 Outputs – see output.tf:
  • private_route_table_id – ID of the created route table.
  • private_route_table_association_ids – Map of subnet ID → association ID.
───────────────────────────────────────────────────────────────────────
Creates a route table attached to the VPC that forwards all traffic
(0.0.0.0/0) to the Internet Gateway (`var.igw_id`).
Tags are applied for identification and cost tracking.
*/

resource "aws_route_table" "private-route-table" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_id
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.tags.Project}-${var.tags.Environment}-private-route-table"
      Environment = var.tags.Environment
    }
  )
}

/* Add peering routes if peering is enabled */
resource "aws_route" "peering_private" {
  for_each = var.peering_routes

  route_table_id            = aws_route_table.private-route-table.id
  destination_cidr_block    = each.value.cidr_block
  vpc_peering_connection_id = each.value.peering_id
}

/*
---------------------------------------------------------------------
aws_route_table_association "private"
---------------------------------------------------------------------
Associates the above route table with each private subnet. The `for_each`
iterates over `var.private_subnets_cidr` (expected to be a list of
subnet IDs or CIDR strings that map to subnet IDs). Adjust the variable
type if you prefer to pass explicit subnet IDs.
*/

resource "aws_route_table_association" "private" {
  for_each       = { for idx, subnet_id in var.private_subnets_cidr : idx => subnet_id }
  subnet_id      = each.value
  route_table_id = aws_route_table.private-route-table.id
}
