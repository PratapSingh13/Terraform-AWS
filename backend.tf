terraform {
  backend "s3" {
    bucket  = "mybucket"
    key     = "terraform/state"
    region  = "ap-south-1"
    encrypt = true
  }
}
