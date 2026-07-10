resource "aws_iam_role" "this" {
  for_each = var.roles

  name = coalesce(each.value.name, each.key)

  assume_role_policy = jsonencode(each.value.assume_role_policy)

  description = lookup(each.value, "description", null)
  path        = lookup(each.value, "path", "/")

  max_session_duration = lookup(each.value, "max_session_duration", 3600)

  tags = merge(
    var.tags,
    {
      Name        = "${var.tags.Project}-${var.tags.Environment}-iam-role-${each.key}"
      Environment = var.tags.Environment
    }
  )
}
