variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "client" {
  description = "Short client identifier, used in resource names."
  type        = string
}

variable "network_id" {
  type = string
}

variable "peer_ip" {
  type = string
}

variable "local_cidr" {
  type = string
}

variable "peer_ranges" {
  type = list(string)
}

variable "shared_secret" {
  type      = string
  sensitive = true
}
