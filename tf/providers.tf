# providers.tf
provider "freeipa" {
  host     = "idm2.idm.norme.sh"
  username = data.external.tofu_idm_api_creds.result.username
  password = data.external.tofu_idm_api_creds.result.password
  insecure = true
}

provider "incus" {
}

provider "proxmox" {
  endpoint = var.proxmox_api_url
  username = data.external.proxmox_admin_creds.result.username
  password = data.external.proxmox_admin_creds.result.password
  insecure = var.pm_tls_insecure
  ssh {
    agent    = true
    username = "root"
  }
}
