# minio.tf

# Create MinIO VM
resource "proxmox_virtual_environment_vm" "minio_vm" {
  name        = "minio.idm.norme.sh"
  description = "MinIO server, managed by OpenTofu"
  node_name   = var.proxmox_node_name
  tags        = ["tofu", "debian", "minio"]
  vm_id       = 1000

  clone {
    vm_id = var.deb_template_id
  }

  agent {
    enabled = true
  }
  stop_on_destroy = true

  memory {
    dedicated = 2048
    floating  = 768
  }

  initialization {
    datastore_id = var.proxmox_storage_img

    dns {
      domain  = "idm.norme.sh"
      servers = ["192.168.225.6", "192.168.225.7"]
    }

    ip_config {
      ipv4 {
        address = "${var.minio_ip}/24"
        gateway = "192.168.225.1"
      }
      ipv6 {
        address = "auto"
      }
    }

    user_account {
      keys     = ["${var.minio_ssh_pubkey}"]
      username = data.external.deb_template_creds.result.username
      password = data.external.deb_template_creds.result.password
    }
  }

  startup {
    order    = "5"
    up_delay = "10"
  }
}

# Copy and execute MinIO setup script
resource "null_resource" "minio_setup" {
  depends_on = [proxmox_virtual_environment_vm.minio_vm]
  #depends_on = [proxmox_virtual_environment_vm.minio_vm, proxmox_virtual_environment_file.minio_setup_script]

  provisioner "file" {
    #source     = "${proxmox_virtual_environment_file.minio_setup_script.datastore_id}:snippets/minio-setup.sh"
    source      = "scripts/minio-setup.sh"
    destination = "minio-setup.sh"
    connection {
      type           = "ssh"
      host           = var.minio_ip
      user           = data.external.deb_template_creds.result.username
      agent          = true
      agent_identity = "nenorman@normesh"
      timeout        = "5m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 640 minio-setup.sh && sudo bash minio-setup.sh"
    ]
    connection {
      type           = "ssh"
      host           = var.minio_ip
      user           = data.external.deb_template_creds.result.username
      agent          = true
      agent_identity = "nenorman@normesh"
      timeout        = "5m"
    }
  }
}

