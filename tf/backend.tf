# backend.tf
terraform {
  backend "s3" {
    endpoint                    = "http://minio.idm.norme.sh:9000" # Use hostname assuming DNS
    bucket                      = "terraform-state"
    key                         = "terraform.tfstate"
    region                      = "us-east-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
  }
}
