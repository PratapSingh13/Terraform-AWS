resource "aws_iam_user" "this" {
  for_each = var.users

  name          = each.key
  force_destroy = true
  tags = merge(
    each.value.tags,
    {
      Name        = "${each.value.tags.Project}-${each.value.tags.Environment}-user"
      Environment = each.value.tags.Environment
    }
  )
}

resource "aws_iam_user_login_profile" "this" {
  # Only create this resource if console_access is true AND no custom password is provided
  # because we'll handle the custom password case with the CLI.
  for_each = {
    for name, config in var.users : name => config
    if config.console_access && config.password == null
  }

  user                    = aws_iam_user.this[each.key].name
  pgp_key                 = each.value.pgp_key
  password_length         = each.value.password_length
  password_reset_required = true

  depends_on = [aws_iam_user.this]
}

# New resource to handle custom passwords via CLI
resource "null_resource" "custom_password" {
  for_each = {
    for name, config in var.users : name => config
    if config.console_access && config.password != null
  }

  triggers = {
    user_name = aws_iam_user.this[each.key].name
    password  = each.value.password
  }

  provisioner "local-exec" {
    command = "aws iam create-login-profile --user-name ${self.triggers.user_name} --password '${self.triggers.password}' --password-reset-required || aws iam update-login-profile --user-name ${self.triggers.user_name} --password '${self.triggers.password}' --password-reset-required"
  }

  depends_on = [aws_iam_user.this]
}

resource "aws_iam_user_policy_attachment" "change_password" {
  for_each   = { for name, config in var.users : name => config if config.console_access }
  user       = aws_iam_user.this[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}
