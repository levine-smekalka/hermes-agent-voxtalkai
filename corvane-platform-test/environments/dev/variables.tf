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
  type      = string
  sensitive = true
}
