variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type    = string
  default = "core-db"
}

variable "tier" {
  type = string
}

variable "availability_type" {
  type    = string
  default = "ZONAL"
}

variable "pitr_enabled" {
  type    = bool
  default = false
}

variable "authorized_networks" {
  description = "Name => CIDR allowed to reach the instance's public IP."
  type        = map(string)
  default     = {}
}

variable "app_password" {
  type      = string
  sensitive = true
}
