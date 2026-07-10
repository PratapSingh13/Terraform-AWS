############################################
# 🔹 NACL RESOURCE
############################################
resource "aws_network_acl" "this" {
  for_each = var.nacls

  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name        = "eip-${var.tags.Project}-${var.tags.Environment}"
      Environment = var.tags.Environment
    },
    lookup(each.value, "tags", {})
  )
}

############################################
# 🔹 INGRESS RULES
############################################
resource "aws_network_acl_rule" "ingress" {
  for_each = merge([
    for nacl_name, nacl_config in var.nacls : {
      for rule in lookup(nacl_config, "ingress", []) :
      "${nacl_name}-ingress-${rule.rule_number}" => {
        nacl_name = nacl_name
        rule      = rule
      }
    }
  ]...)

  network_acl_id = aws_network_acl.this[each.value.nacl_name].id
  rule_number    = each.value.rule.rule_number
  egress         = false
  protocol       = each.value.rule.protocol
  rule_action    = each.value.rule.action
  cidr_block     = each.value.rule.cidr_block
  from_port      = each.value.rule.from_port
  to_port        = each.value.rule.to_port
}

############################################
# 🔹 EGRESS RULES
############################################
resource "aws_network_acl_rule" "egress" {
  for_each = merge([
    for nacl_name, nacl_config in var.nacls : {
      for rule in lookup(nacl_config, "egress", []) :
      "${nacl_name}-egress-${rule.rule_number}" => {
        nacl_name = nacl_name
        rule      = rule
      }
    }
  ]...)

  network_acl_id = aws_network_acl.this[each.value.nacl_name].id
  rule_number    = each.value.rule.rule_number
  egress         = true
  protocol       = each.value.rule.protocol
  rule_action    = each.value.rule.action
  cidr_block     = each.value.rule.cidr_block
  from_port      = each.value.rule.from_port
  to_port        = each.value.rule.to_port
}

############################################
# 🔹 NORMALIZED SUBNET RESOLUTION
############################################
locals {
  nacl_subnets = {
    for nacl_name, nacl_config in var.nacls :
    nacl_name => distinct(concat(
      lookup(nacl_config, "subnet_ids", []),
      flatten([
        for key in lookup(nacl_config, "subnet_keys", []) :
        lookup(var.subnet_map, key, [])
      ])
    ))
  }
}

############################################
# 🔹 SUBNET ASSOCIATION
############################################
# resource "aws_network_acl_association" "this" {
#   depends_on = [
#     aws_network_acl.this
#   ]

#   for_each = {
#     for idx, item in flatten([
#       for nacl_name, subnet_list in local.nacl_subnets : [
#         for subnet_id in subnet_list : {
#           nacl_name = nacl_name
#           subnet_id = subnet_id
#         }
#       ]
#     ]) :
#     "${item.nacl_name}-${idx}" => item
#   }

#   network_acl_id = aws_network_acl.this[each.value.nacl_name].id
#   subnet_id      = each.value.subnet_id
# }

resource "aws_network_acl_association" "this" {
  count = length(flatten([
    for nacl_name, subnet_list in local.nacl_subnets :
    subnet_list
  ]))
  subnet_id = flatten([
    for nacl_name, subnet_list in local.nacl_subnets :
    subnet_list
  ])[count.index]
  network_acl_id = values(aws_network_acl.this)[0].id
}
