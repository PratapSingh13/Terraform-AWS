provider "aws" {
  region = var.region

  assume_role {
    role_arn     = "arn:aws:iam::590379872770:role/TerraformProvisioningPolicy"
  }
}
