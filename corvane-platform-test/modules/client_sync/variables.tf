variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "client" {
  type = string
}

variable "image" {
  type = string
}

variable "schedule" {
  type = string
}

variable "paused" {
  type    = bool
  default = false
}

variable "timeout" {
  type    = string
  default = "14400s"
}

variable "memory" {
  type    = string
  default = "1Gi"
}

variable "write_enabled" {
  type    = bool
  default = false
}

variable "service_account_email" {
  type = string
}

variable "scheduler_service_account_email" {
  type = string
}
