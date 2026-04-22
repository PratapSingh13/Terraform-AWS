locals {
  create = var.create
  tags   = merge(var.tags, { terraform-aws-modules = "sg" })
}
