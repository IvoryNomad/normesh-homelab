#cloud-config
%{ if bootcmds != [] ~}
bootcmd:
%{ for bcmd in bootcmds ~}
  - ${bcmd}
%{ endfor ~}
%{ endif ~}

hostname: ${hostname}
fqdn: ${fqdn}

users:
  - name: localadmin
    groups: adm
    shell: /bin/bash
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
%{ for key in ssh_keys ~}
      - "${key}"
%{ endfor ~}
%{ if local_users != [] ~}
%{ for username, user_cfg in local_users ~}
  - name: ${username}
    groups:
%{ for group in user_cfg.groups ~}
      - ${group}
%{ endfor ~}
    lock_passwd: ${user_cfg.lock_passwd}
    sudo: ${user_cfg.sudo}
    ssh_authorized_keys:
%{ for key in ssh_keys ~}
      - "${key}"
%{ endfor ~}
%{ endfor ~}
%{ endif ~}

%{ if additional_packages != [] ~}
packages:
%{ for package in additional_packages ~}
  - ${package}
%{ endfor ~}
%{ endif ~}

%{ if runcmds != [] ~}
runcmd:
%{ for rcmd in runcmds ~}
  - ${rcmd} 
%{ endfor ~}
%{ endif ~}
