terraform {
  backend "s3" {
    bucket  = "nagarro-terraform-state-file"
    key     = "terraform/state"
    region  = "ap-south-1"
    encrypt = true
  }
}
