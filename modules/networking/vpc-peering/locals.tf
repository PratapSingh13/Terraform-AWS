locals {
  tags = merge(var.tags, { terraform-aws-modules = "vpc_peering" })
}
