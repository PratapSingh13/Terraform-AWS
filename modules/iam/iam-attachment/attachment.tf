############################################
# 🔹 ROLE ATTACHMENTS
############################################
resource "aws_iam_role_policy_attachment" "role_attach" {
  for_each = merge([
    for role_name, policies in var.role_attachments : {
      for policy_key in policies :
      "${role_name}-${policy_key}" => {
        role_name  = role_name
        policy_key = policy_key
      }
    }
  ]...)

  role       = each.value.role_name
  policy_arn = var.policy_arns[each.value.policy_key]
}

############################################
# 🔹 USER ATTACHMENTS
############################################
resource "aws_iam_user_policy_attachment" "user_attach" {
  for_each = merge([
    for user_name, policies in var.user_attachments : {
      for policy_key in policies :
      "${user_name}-${policy_key}" => {
        user_name  = user_name
        policy_key = policy_key
      }
    }
  ]...)

  user       = each.value.user_name
  policy_arn = var.policy_arns[each.value.policy_key]
}

############################################
# 🔹 GROUP ATTACHMENTS
############################################
resource "aws_iam_group_policy_attachment" "group_attach" {
  for_each = merge([
    for group_name, policies in var.group_attachments : {
      for policy_key in policies :
      "${group_name}-${policy_key}" => {
        group_name = group_name
        policy_key = policy_key
      }
    }
  ]...)

  group      = each.value.group_name
  policy_arn = var.policy_arns[each.value.policy_key]
}