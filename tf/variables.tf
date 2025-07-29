# variables.tf
variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://pve-lab.ipa.norme.sh:8006/api2/json"
}

variable "pm_tls_insecure" {
  description = "Whether to skip TLS verification for Proxmox API"
  type        = bool
  default     = true
}

variable "proxmox_node_name" {
  description = "Proxmox node name"
  type        = string
  default     = "pve-lab"
}

variable "proxmox_storage_tmpl" {
  description = "Proxmox storage pool for templates"
  type        = string
  default     = "local"
}

variable "proxmox_storage_img" {
  description = "Proxmox storage pool for images"
  type        = string
  default     = "local-zfs"
}

variable "deb_template_id" {
  description = "VM ID for debian vm template"
  type        = number
  default     = 9000
}
