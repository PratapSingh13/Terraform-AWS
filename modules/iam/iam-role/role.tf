resource "aws_iam_role" "this" {
  for_each = var.roles

  name               = each.key
  assume_role_policy = jsonencode(each.value.assume_role_policy)
}
