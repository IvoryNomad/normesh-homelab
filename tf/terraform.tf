# terraform.tf
terraform {
  required_providers {
    freeipa = {
      source  = "rework-space-com/freeipa"
      version = "~> 5.0.1"
    }

    incus = {
      source  = "lxc/incus"
      version = "0.3.1"
    }

    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.78.0"
    }
  }
}
