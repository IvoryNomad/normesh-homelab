# dns-backup.tf

# upload cloud-config snippets
resource "proxmox_virtual_environment_file" "cloud_init_network_config" {
  for_each      = local.dns_backup_vms

  content_type  = "snippets"
  datastore_id  = each.value.snippet_datastore
  node_name     = each.value.pve_node

  source_raw {
    file_name = "vm-${each.value.vm_id}-network-config.yml"
    data      = templatefile("cloud-init-network-config.yml.tpl", {
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
}

resource "proxmox_virtual_environment_file" "cloud_init_user_data" {
  for_each      = local.dns_backup_vms

  content_type  = "snippets"
  datastore_id  = each.value.snippet_datastore
  node_name     = each.value.pve_node

  source_raw {
    file_name = "vm-${each.value.vm_id}-user-data.yml"
    data      = templatefile("cloud-init-user-data.yml.tpl", {
      bootcmds            = each.value.bootcmds
      hostname            = each.value.hostname
      fqdn                = each.value.fqdn
      local_users         = each.value.local_users
      ssh_keys            = local.ssh_keys
      additional_packages = each.value.additional_packages
      runcmds             = each.value.runcmds
    })
  }
}

# Create proxmox cloned VMs
resource "proxmox_virtual_environment_vm" "cloned_vms" {
  for_each    = local.dns_backup_vms

  name        = each.key
  vm_id       = each.value.vm_id
  tags        = each.value.tags
  node_name   = each.value.pve_node
  description = "${each.value.fqdn}, managed by opentofu"

  clone {
    vm_id = each.value.clone_id
  }

  agent {
    enabled = each.value.agent_enabled
  }
  stop_on_destroy = true

  cpu {
    cores = each.value.cpu_cores
    type  = each.value.cpu_type
  }

  memory {
    dedicated = each.value.mem_dedicated
    floating  = each.value.mem_floating
  }

  network_device {
    bridge = each.value.net_dev
    queues = each.value.cpu_cores
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = each.value.image_datastore

    # we provide cloud-init files instead of creating specific configs
    # here. If that is desired, this should be fixed to determine
    # whether a file path is provided via the vars file
    network_data_file_id = proxmox_virtual_environment_file.cloud_init_network_config[each.key].id
    user_data_file_id    = proxmox_virtual_environment_file.cloud_init_user_data[each.key].id
  }

  startup {
    order     = 10
    up_delay  = 0
  }

# provisioner "local-exec" {
#   command = "ssh-keygen -f ~/.ssh/known_hosts -R ${each.value.ipv4_addr}"
#   when    = destroy
# }

  provisioner "local-exec" {
    command = <<EOF
      cd ../ansible
      ssh-keygen -f ~/.ssh/known_hosts -R ${each.value.ipv4_addr}
      ansible-playbook wait_for_connect.yml --limit ${each.value.fqdn}
    EOF
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "false"
    }
  }

  provisioner "local-exec" {
    command = <<EOF
      cd ../ansible
      ansible-playbook 00-playbook-ssh-keys.yml --limit ${each.value.fqdn}
      ansible-playbook fix-cloud-init.yml --limit ${each.value.fqdn}
      ansible-playbook knot-resolver.yml --limit ${each.value.fqdn}
    EOF
  }
}

