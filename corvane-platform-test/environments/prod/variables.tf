variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "db_app_password" {
  description = "Supplied by CI from Secret Manager."
  type        = string
  sensitive   = true
}

variable "vpn_shared_secrets" {
  description = "Client => IPsec pre-shared key. Supplied by CI from Secret Manager."
  type        = map(string)
  sensitive   = true
}
