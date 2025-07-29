# vars-proxmox.tf

locals {
  proxmox_cloned_vms = {
    dns-backup1 = {
      vm_id             = 1000
      tags              = []
      pve_node          = "pve-lab"
      clone_id          = 9900
      agent_enabled     = true
      cpu_cores         = 2
      cpu_type          = "x86-64-v3"
      mem_dedicated     = 1024
      mem_floating      = 512
      net_dev           = "vmbr21"
      image_datastore   = "tank"
      snippet_datastore = "local"

      bootcmds = []

      hostname  = "dns-backup1"
      fqdn      = "dns-backup1.ipa.norme.sh"
      ifname    = "ens18"
      ipv4_addr = "192.168.226.32"
      ipv4_mask = "24"
      ipv4_gw   = "192.168.226.1"
      ipv6_addr = "2001:470:e0fc:2::20"
      ipv6_mask = "64"
      ipv6_gw   = "2001:470:e0fc:2::1"

      # needs to at least be defined as an empty list?
      local_users = []

      additional_packages = []

      runcmds = []
    }
    dns-backup2 = {
      vm_id             = 1001
      tags              = []
      pve_node          = "pve-lab"
      clone_id          = 9900
      agent_enabled     = true
      cpu_cores         = 2
      cpu_type          = "x86-64-v3"
      mem_dedicated     = 1024
      mem_floating      = 512
      net_dev           = "vmbr21"
      image_datastore   = "tank"
      snippet_datastore = "local"

      bootcmds = []

      hostname  = "dns-backup2"
      fqdn      = "dns-backup2.ipa.norme.sh"
      ifname    = "ens18"
      ipv4_addr = "192.168.226.33"
      ipv4_mask = "24"
      ipv4_gw   = "192.168.226.1"
      ipv6_addr = "2001:470:e0fc:2::21"
      ipv6_mask = "64"
      ipv6_gw   = "2001:470:e0fc:2::1"

      # needs to at least be defined as an empty list?
      local_users = []

      additional_packages = []

      runcmds = []
    }
    dns-backup3 = {
      vm_id             = 1002
      tags              = []
      pve_node          = "pve-lab"
      clone_id          = 9900
      agent_enabled     = true
      cpu_cores         = 2
      cpu_type          = "x86-64-v3"
      mem_dedicated     = 1024
      mem_floating      = 512
      net_dev           = "vmbr21"
      image_datastore   = "tank"
      snippet_datastore = "local"

      bootcmds = []

      hostname  = "dns-backup3"
      fqdn      = "dns-backup3.ipa.norme.sh"
      ifname    = "ens18"
      ipv4_addr = "192.168.226.34"
      ipv4_mask = "24"
      ipv4_gw   = "192.168.226.1"
      ipv6_addr = "2001:470:e0fc:2::22"
      ipv6_mask = "64"
      ipv6_gw   = "2001:470:e0fc:2::1"

      # needs to at least be defined as an empty list?
      local_users = []

      additional_packages = []

      runcmds = []
    }
  }
}
