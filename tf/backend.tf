# backend.tf
terraform {
  backend "s3" {
    bucket         = "normesh-homelab-tofu-state"
    key            = "normesh-homelab/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tofu-state-lock"
    encrypt        = true
  }
}
