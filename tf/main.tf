# main.tf
data "external" "deb_template_creds" {
  program = ["bash", "-c", "op_wrapper item get deb-template-creds --vault CICD-homelab --fields username,password --format json | jq 'reduce .[] as $item ({}; .[$item.label] = $item.value)'"]
}

data "external" "proxmox_admin_creds" {
  program = ["bash", "-c", "op_wrapper item get proxmox-root --vault CICD-homelab --fields username,password --format json | jq 'reduce .[] as $item ({}; .[$item.label] = $item.value)'"]
}

data "external" "tofu_idm_api_creds" {
  program = ["bash", "-c", "op_wrapper item get tofu-idm-api --vault CICD-homelab --fields username,password --format json | jq 'reduce .[] as $item ({}; .[$item.label] = $item.value)'"]
}
