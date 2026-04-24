resource "aws_iam_policy" "this" {
  for_each = var.policies

  name        = each.key
  description = each.value.description
  policy      = jsonencode(each.value.policy)
}
