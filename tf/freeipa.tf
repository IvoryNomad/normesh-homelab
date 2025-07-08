# incus.tf

resource "incus_instance" "ipa1" {
  name        = "ipa1"
  image       = "alma-9-cloud-tmpl"
  type        = "container"
  remote      = "vmhost0"
  description = "ipa1.ipa.norme.sh, managed by opentofu"

  config = {
    "cloud-init.user-data" = <<-EOT
      #cloud-config
      hostname: ipa1
      fqdn: ipa1.ipa.norme.sh

      users:
        - name: localadmin
          groups: adm
          lock_passwd: false
          sudo: ALL=(ALL) NOPASSWD:ALL
          ssh_authorized_keys:
            - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIh3xF5/PwXtFQexMzoEbKI0dFE/Ddu2CdD+Y9OJX5HW ansible@normesh"
            - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIzfTYaJ7JmPK5ZqPVDvFAfsnwXb8wtJj+FzFbMCuLpV nenorman@normesh"
    EOT

    "cloud-init.network-config" = <<-EOT
      version: 1
      config:
        - type: physical
          name: eth0
          subnets:
          - type: static
            address: '192.168.226.2/24'
            gateway: '192.168.226.1'
          - type: static6
            address: '2001:470:e0fc:2::2/64'
            gateway: '2001:470:e0fc:2::1'
        - type: nameserver
          address:
          - '192.168.225.6'
          - '192.168.225.7'
          search:
          - 'ipa.norme.sh'
    EOT
  }

  profiles = ["storage", "net-vmbr21", "freeipa-server"]

  running = true

  wait_for {
    type  = "delay"
    delay = "30s"
  }

  provisioner "local-exec" {
    command = "cd ../ansible && ansible-playbook -i inventory.yml 00-playbook-ssh-keys.yml --limit ipa1.ipa.norme.sh"
  }

  provisioner "local-exec" {
    command = "cd ../ansible && ansible-playbook -i inventory.yml freeipa-server.yml --tags install,reboot,backup --limit ipa1.ipa.norme.sh"
  }

  provisioner "local-exec" {
    command = "incus snapshot create vmhost0:ipa1 first-master-configured"
  }
}

output "ipa1_ipv4" {
  value       = incus_instance.ipa1.ipv4_address
  description = "IPv4 address of ipa1"
}

output "ipa1_status" {
  value       = incus_instance.ipa1.status
  description = "Status of ipa1"
}


resource "incus_instance" "ipa2" {
  name        = "ipa2"
  image       = "alma-9-cloud-tmpl"
  type        = "container"
  remote      = "vmhost0"
  description = "ipa2.ipa.norme.sh, managed by opentofu"

  # ensure first master exists
  depends_on = [
    incus_instance.ipa1
  ]

  config = {
    "cloud-init.user-data" = <<-EOT
      #cloud-config
      hostname: ipa2
      fqdn: ipa2.ipa.norme.sh

      users:
        - name: localadmin
          groups: adm
          lock_passwd: false
          sudo: ALL=(ALL) NOPASSWD:ALL
          ssh_authorized_keys:
            - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIh3xF5/PwXtFQexMzoEbKI0dFE/Ddu2CdD+Y9OJX5HW ansible@normesh"
            - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIzfTYaJ7JmPK5ZqPVDvFAfsnwXb8wtJj+FzFbMCuLpV nenorman@normesh"
    EOT

    "cloud-init.network-config" = <<-EOT
      version: 1
      config:
        - type: physical
          name: eth0
          subnets:
          - type: static
            address: '192.168.226.3/24'
            gateway: '192.168.226.1'
          - type: static6
            address: '2001:470:e0fc:2::3/64'
            gateway: '2001:470:e0fc:2::1'
        - type: nameserver
          address:
          - '192.168.225.6'
          - '192.168.225.7'
          search:
          - 'ipa.norme.sh'
    EOT
  }

  profiles = ["storage", "net-vmbr21", "freeipa-server"]

  running = true

  wait_for {
    type  = "delay"
    delay = "30s"
  }

  provisioner "local-exec" {
    command = "cd ../ansible && ansible-playbook -i inventory.yml 00-playbook-ssh-keys.yml --limit ipa2.ipa.norme.sh"
  }

  provisioner "local-exec" {
    command = "cd ../ansible && ansible-playbook -i inventory.yml freeipa-server.yml --tags install,reboot --limit ipa2.ipa.norme.sh"
  }

  provisioner "local-exec" {
    command = "incus snapshot create vmhost0:ipa2 replica-configured"
  }
}

output "ipa2_ipv4" {
  value       = incus_instance.ipa2.ipv4_address
  description = "IPv4 address of ipa2"
}

output "ipa2_status" {
  value       = incus_instance.ipa2.status
  description = "Status of ipa2"
}

resource "incus_instance" "ipa3" {
  name        = "ipa3"
  image       = "alma-9-cloud-tmpl"
  type        = "container"
  remote      = "vmhost0"
  description = "ipa3.ipa.norme.sh, managed by opentofu"

  # ensure first master exists
  depends_on = [
    incus_instance.ipa1,
    incus_instance.ipa2
  ]

  config = {
    "cloud-init.user-data" = <<-EOT
      #cloud-config
      hostname: ipa3
      fqdn: ipa3.ipa.norme.sh

      users:
        - name: localadmin
          groups: adm
          lock_passwd: false
          sudo: ALL=(ALL) NOPASSWD:ALL
          ssh_authorized_keys:
            - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIh3xF5/PwXtFQexMzoEbKI0dFE/Ddu2CdD+Y9OJX5HW ansible@normesh"
            - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIzfTYaJ7JmPK5ZqPVDvFAfsnwXb8wtJj+FzFbMCuLpV nenorman@normesh"
    EOT

    "cloud-init.network-config" = <<-EOT
      version: 1
      config:
        - type: physical
          name: eth0
          subnets:
          - type: static
            address: '192.168.226.4/24'
            gateway: '192.168.226.1'
          - type: static6
            address: '2001:470:e0fc:2::4/64'
            gateway: '2001:470:e0fc:2::1'
        - type: nameserver
          address:
          - '192.168.225.6'
          - '192.168.225.7'
          search:
          - 'ipa.norme.sh'
    EOT
  }

  profiles = ["storage", "net-vmbr21", "freeipa-server"]

  running = true

  wait_for {
    type  = "delay"
    delay = "30s"
  }

  provisioner "local-exec" {
    command = "cd ../ansible && ansible-playbook -i inventory.yml 00-playbook-ssh-keys.yml --limit ipa3.ipa.norme.sh"
  }

  provisioner "local-exec" {
    command = "cd ../ansible && ansible-playbook -i inventory.yml freeipa-server.yml --tags install,reboot --limit ipa3.ipa.norme.sh"
  }

  provisioner "local-exec" {
    command = "incus snapshot create vmhost0:ipa3 replica-configured"
  }
}

output "ipa3_ipv4" {
  value       = incus_instance.ipa3.ipv4_address
  description = "IPv4 address of ipa3"
}

output "ipa3_status" {
  value       = incus_instance.ipa3.status
  description = "Status of ipa3"
}
