# freeipa.tf

resource "incus_instance" "ipa_servers" {
  for_each    = local.ipa_servers

  name        = each.key
  # image       = "alma-9-cloud-tmpl"
  image       = "images:almalinux/9/cloud"
  type        = "container"
  remote      = "cluster0"
  description = "${each.value.fqdn}, managed by opentofu"

  config = {
    "cloud-init.user-data" = templatefile("cloud-init-user-data.yml.tpl", {
      bootcmds            = each.value.bootcmds
      hostname            = each.value.hostname
      fqdn                = each.value.fqdn
      local_users         = each.value.local_users
      ssh_keys            = local.ssh_keys
      additional_packages = each.value.additional_packages
      runcmds             = each.value.runcmds
    })

    "cloud-init.network-config" = templatefile("cloud-init-network-config.yml.tpl", {
      ifname          = each.value.ifname
      ipv4_addr       = each.value.ipv4_addr
      ipv4_mask       = each.value.ipv4_mask
      ipv4_gw         = each.value.ipv4_gw
      ipv6_addr       = each.value.ipv6_addr
      ipv6_mask       = each.value.ipv6_mask
      ipv6_gw         = each.value.ipv6_gw
      dns_servers     = local.dns_servers
      search_domains  = local.search_domains
    })
  }

  profiles = ["default", "freeipa-server"]

  running = true

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for cloud-init to complete..."

      incus exec cluster0:${each.key} -- cloud-init status --wait >/dev/null 2>&1
      RC=$?
      if [ $RC -eq 0 ]; then
        echo "Cloud-init completed successfully"
      elif [ $RC -eq 2 ]; then
        echo "Cloud-init had recoverable errors"
        incus exec cluster0:${each.key} -- cloud-init status --long
        exit 0
      else
        echo "Cloud-init failed!"
        incus exec cluster0:${each.key} -- cloud-init status --long
        exit 1
      fi
    EOT
  }

  provisioner "local-exec" {
    command = "cd ../ansible && ansible-playbook -i inventory.yml 00-playbook-ssh-keys.yml --limit ${each.value.fqdn}"
  }

  provisioner "local-exec" {
    command = "cd ../ansible && ansible-playbook -i inventory.yml freeipa-server.yml --tags install,backup --limit ${each.value.fqdn}"
  }

  provisioner "local-exec" {
    command = "incus snapshot create cluster0:${each.key} ${each.value.snapshot_name}"
  }
}
