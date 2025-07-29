# vars-freeipa.tf

locals {
  ipa_servers = {
    ipa1 = {
      bootcmds = [
        "mkdir -p /etc/systemd/system/systemd-hostnamed.service.d",
        "echo '[Service]' > /etc/systemd/system/systemd-hostnamed.service.d/override.conf",
        "echo 'PrivateNetwork=no' >> /etc/systemd/system/systemd-hostnamed.service.d/override.conf",
        "systemctl daemon-reload"
      ]

      hostname  = "ipa1"
      fqdn      = "ipa1.ipa.norme.sh"
      ifname    = "eth0"
      ipv4_addr = "192.168.226.2"
      ipv4_mask = "24"
      ipv4_gw   = "192.168.226.1"
      ipv6_addr = "2001:470:e0fc:2::2"
      ipv6_mask = "64"
      ipv6_gw   = "2001:470:e0fc:2::1"

      # needs to at least be defined as an empty list?
      local_users = []

      additional_packages  = [
        "epel-release",
        "openssh-server"
      ]

      runcmds = [
        # RHEL is retarded and doesn't honor the lock_passwd directive in cloud-config
        "sed -i 's/^localadmin:[^:]*:/localadmin:*:/' /etc/shadow",
        "mv /etc/ssh/sshd_config.rpmnew /etc/ssh/sshd_config",
        "systemctl enable sshd",
        "systemctl start sshd"
      ]

      snapshot_name = "first-master-configured"
    }
    ipa2 = {
      bootcmds = [
        "mkdir -p /etc/systemd/system/systemd-hostnamed.service.d",
        "echo '[Service]' > /etc/systemd/system/systemd-hostnamed.service.d/override.conf",
        "echo 'PrivateNetwork=no' >> /etc/systemd/system/systemd-hostnamed.service.d/override.conf",
        "systemctl daemon-reload"
      ]

      hostname  = "ipa2"
      fqdn      = "ipa2.ipa.norme.sh"
      ifname    = "eth0"
      ipv4_addr = "192.168.226.3"
      ipv4_mask = "24"
      ipv4_gw   = "192.168.226.1"
      ipv6_addr = "2001:470:e0fc:2::3"
      ipv6_mask = "64"
      ipv6_gw   = "2001:470:e0fc:2::1"

      # needs to at least be defined as an empty list?
      local_users = []

      additional_packages  = [
        "epel-release",
        "openssh-server"
      ]

      runcmds = [
        # RHEL is retarded and doesn't honor the lock_passwd directive in cloud-config
        "sed -i 's/^localadmin:[^:]*:/localadmin:*:/' /etc/shadow",
        "mv /etc/ssh/sshd_config.rpmnew /etc/ssh/sshd_config",
        "systemctl enable sshd",
        "systemctl start sshd"
      ]

      snapshot_name = "replica-configured"
    }
    ipa3 = {
      bootcmds = [
        "mkdir -p /etc/systemd/system/systemd-hostnamed.service.d",
        "echo '[Service]' > /etc/systemd/system/systemd-hostnamed.service.d/override.conf",
        "echo 'PrivateNetwork=no' >> /etc/systemd/system/systemd-hostnamed.service.d/override.conf",
        "systemctl daemon-reload"
      ]

      hostname  = "ipa3"
      fqdn      = "ipa3.ipa.norme.sh"
      ifname    = "eth0"
      ipv4_addr = "192.168.226.4"
      ipv4_mask = "24"
      ipv4_gw   = "192.168.226.1"
      ipv6_addr = "2001:470:e0fc:2::4"
      ipv6_mask = "64"
      ipv6_gw   = "2001:470:e0fc:2::1"

      # needs to at least be defined as an empty list?
      local_users = []

      additional_packages  = [
        "epel-release",
        "openssh-server"
      ]

      runcmds = [
        # RHEL is retarded and doesn't honor the lock_passwd directive in cloud-config
        "sed -i 's/^localadmin:[^:]*:/localadmin:*:/' /etc/shadow",
        "mv /etc/ssh/sshd_config.rpmnew /etc/ssh/sshd_config",
        "systemctl enable sshd",
        "systemctl start sshd"
      ]

      snapshot_name = "replica-configured"
    }
  }
}
