# Attach policies to roles
resource "aws_iam_role_policy_attachment" "role_attach" {
  for_each = var.role_policy_attachments

  role       = each.value.role
  policy_arn = each.value.policy_arn
}

# Attach policies to users
resource "aws_iam_user_policy_attachment" "user_attach" {
  for_each = var.user_policy_attachments

  user       = each.value.user
  policy_arn = each.value.policy_arn
}
