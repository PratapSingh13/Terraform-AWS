resource "aws_iam_policy" "this" {
  for_each = var.policies

  name        = coalesce(each.value.name, each.key)
  description = each.value.description
  policy      = jsonencode(each.value.policy)

  tags = merge(
    var.tags,
    {
      Name        = "${var.tags.Project}-${var.tags.Environment}-iam-policy-${each.key}"
      Environment = var.tags.Environment
    }
  )
}