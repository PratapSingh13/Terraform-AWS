/*
──────────────────────────────────────────────────────────────────────
Security Group Module – Networking
──────────────────────────────────────────────────────────────────────
📌 Purpose:  Define an optional security group (SG) for the VPC and
            expose a flexible, declarative way to configure inbound
            and outbound rules via input maps.
📅 Created: 14‑01‑2026
👤 Owner:   Yogendra Pratap Singh (yogendra.singh01@nagarro.com)
🏢 Team:    Infrastructure / DevOps
💰 Cost Center: 12345‑AWS‑SECURITY‑GROUP
🌍 Region: ${var.aws_region}
🗂️ Components:
  - aws_security_group                – SG resource (optional)
  - aws_vpc_security_group_ingress_rule – Ingress rules
  - aws_vpc_security_group_egress_rule  – Egress rules
🔗 References:
  – AWS Security Groups docs: https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html
  – Terraform AWS Provider (SG): https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
  – Terraform AWS Provider (Ingress/Egress rules):
    https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
    https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule
🔐 Security / Compliance:
  - SG creation is gated by `var.create_security_group` – set to
    `false` for environments that rely on default SGs.
  - Tags include `environment` and any user‑provided tags for cost
    allocation and auditability.
📦 Inputs (variables) – see [variables.tf](cci:7://file:///Users/pratapsingh/Desktop/Data/Nagarro/Nagarro%20Internal/Promotion/assignment/terraform/modules/networking/variables.tf:0:0-0:0) in this module:
  - create_security_group          – Boolean, whether to create SG.
  - security_group_name            – Base name for the SG.
  - security_group_use_name_prefix – Use `name_prefix` (true) or
    explicit `name` (false).
  - security_group_description     – SG description.
  - vpc_id                         – VPC ID to attach the SG.
  - security_group_tags            – Additional tags map.
  - security_group_ingress_rules   – Map of ingress rule objects.
  - security_group_egress_rules    – Map of egress rule objects.
📤 Outputs – see [output.tf](cci:7://file:///Users/pratapsingh/Desktop/Data/Nagarro/Nagarro%20Internal/Promotion/assignment/terraform/modules/networking/output.tf:0:0-0:0) in this module:
  - security_group_id – ID of the created SG (or empty string if not created).
──────────────────────────────────────────────────────────────────────
This resource is optional – it is created only when
`var.create_security_group` is true. The name can be either a static
name or a name prefix (which adds a random suffix) based on the
`security_group_use_name_prefix` flag.
*/

resource "aws_security_group" "security_group" {
  count = var.create_security_group ? 1 : 0

  # Name handling – either a fixed name or a generated prefix.
  name        = var.security_group_use_name_prefix ? null : var.security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${var.security_group_name}-" : null

  description = var.security_group_description
  vpc_id      = var.vpc_id

  # Merge default module tags, user‑supplied tags, and the environment tag.
  tags = merge(
    var.tags,
    {
      Name        = "${var.tags.Project}-${var.tags.Environment}-sg"
      Environment = var.tags.Environment
    }
  )

  lifecycle {
    # Ensure the SG is replaced before the old one is destroyed – useful
    # when the SG is referenced by other resources (e.g., ENIs).
    create_before_destroy = true
  }
}

/*
---------------------------------------------------------------------
aws_vpc_security_group_ingress_rule "this"
---------------------------------------------------------------------
Ingress rules are defined via the `security_group_ingress_rules` map.
Each map entry should contain:
  - `ip_protocol` (default “tcp”)
  - `from_port`, `to_port`
  - `cidr_ipv4` (or other CIDR fields)
The rule is attached to the first (and only) SG instance created above.
*/

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = var.security_group_ingress_rules

  security_group_id = aws_security_group.security_group[0].id
  ip_protocol       = try(each.value.ip_protocol, "tcp")
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_ipv4         = each.value.cidr_ipv4
}

/*
---------------------------------------------------------------------
aws_vpc_security_group_egress_rule "this"
---------------------------------------------------------------------
Egress rules follow the same pattern as ingress. When `ip_protocol`
is “-1” (all protocols), `from_port` and `to_port` are omitted.
*/

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = var.security_group_egress_rules

  security_group_id = aws_security_group.security_group[0].id
  ip_protocol       = try(each.value.ip_protocol, "tcp")
  from_port         = each.value.ip_protocol != "-1" ? each.value.from_port : null
  to_port           = each.value.ip_protocol != "-1" ? each.value.to_port : null
  cidr_ipv4         = each.value.cidr_ipv4
}
