/*
──────────────────────────────────────────────────────────────────────
Terraform VPC Peering Module – Networking
──────────────────────────────────────────────────────────────────────
📌 Purpose:     Create a reusable AWS VPC Peering for the <PROJECT‑NAME> environment.
📅 Created:     21-04-2026
👤 Owner:       Yogendra Pratap Singh (yogendra.singh01@nagarro.com)
🏢 Team:        Infrastructure / DevOps
💰 Cost Center: 12345‑AWS‑VPC
🌍 Region:      ${var.aws_region}
📦 CIDR Block:  ${var.vpc_cidr}
🗂️ Components:
  - VPC
  - Internet Gateway
  - Public & Private Subnets (per AZ)
  - Route Tables & Associations
  - NAT Gateways (optional)
  - 
📌 Concept: A VPC peering connection is a networking connection between two VPCs that enables you to route traffic between them using private IPv4 addresses or IPv6 addresses. Instances in either VPC can communicate with each other as if they are within the same network. You can create a VPC peering connection between your own VPCs, or with a VPC in another AWS account. The VPCs can be in different Regions (also known as an inter-Region VPC peering connection).
📚 References:
  – Architecture diagram: https://docs.aws.amazon.com/prescriptive-guidance/latest/integrate-third-party-services/architecture-2.html
  – AWS VPC Peering guide: https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html
  – Terraform AWS Provider docs: https://registry.terraform.io/providers/-/aws/6.8.0/docs/resources/vpc_peering_connection
🔐 Security / Compliance:
  - No public IPs only private subnets
  - All the VPCs which are intended to do peering should have different VPC CIDRs
  - Tags include environment, owner, project, cost_center
🛠️ Inputs (variables) – see variables.tf:
  - vpc_id – ID of the VPC to peer with
  - peer_vpc_id – ID of the existing VPC to peer with
  - auto_accept – Whether to accept the peering connection automatically (only works if both VPCs are in the same account and same region)
  - tags – Map of common tags applied to all resources
📤 Outputs (see outputs.tf):
  - vpc_peering_id
*/

resource "aws_vpc_peering_connection" "peering" {

  vpc_id        = var.origin_vpc_id
  peer_vpc_id   = var.destination_vpc_id
  peer_owner_id = var.destination_vpc_owner_id
  #peer_region  = var.destination_vpc_region
  auto_accept = var.auto_accept

  accepter {
    allow_remote_vpc_dns_resolution = var.allow_remote_vpc_dns_resolution_accepter
  }

  requester {
    allow_remote_vpc_dns_resolution = var.allow_remote_vpc_dns_resolution_requester
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.tags.Project}-${var.tags.Environment}-vpc-peering"
      Environment = var.tags.Environment
    }
  )
}
