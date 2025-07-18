# common-vars.tf

locals {
  ssh_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIh3xF5/PwXtFQexMzoEbKI0dFE/Ddu2CdD+Y9OJX5HW ansible@normesh",
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIzfTYaJ7JmPK5ZqPVDvFAfsnwXb8wtJj+FzFbMCuLpV nenorman@normesh"
  ]

  dns_servers = [
    "192.168.225.32",
    "192.168.225.33",
    "192.168.225.34"
  ]

  search_domains = ["ipa.norme.sh"]
}
