variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "name" {
  type    = string
  default = "automation-engine"
}

variable "machine_type" {
  type = string
}

variable "disk_gb" {
  type    = number
  default = 100
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "subnet_id" {
  type = string
}

variable "service_account_email" {
  type = string
}

variable "snapshot_retention_days" {
  type    = number
  default = 14
}
