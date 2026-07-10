output "user_arns" {
  description = "Map of username => IAM user ARN."
  value = {
    for user_name, user in aws_iam_user.this :
    user_name => user.arn
  }
}

output "user_names" {
  description = "Map of username => IAM user name."
  value = {
    for user_name, user in aws_iam_user.this :
    user_name => user.name
  }
}

output "console_access_users" {
  description = "List of users who have console access enabled."
  value = [
    for user_name, user_config in var.users :
    user_name if user_config.console_access
  ]
}

output "encrypted_passwords" {
  description = "Encrypted passwords for console users (decrypt with PGP private key)."
  value = {
    for user_name, login_profile in aws_iam_user_login_profile.this :
    user_name => login_profile.encrypted_password
  }
  sensitive = true
}
