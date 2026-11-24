variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "location" {
  type    = string
  default = "EU"
}

variable "retention_days" {
  type = number
}

variable "service_account_email" {
  type = string
}

variable "image_repo" {
  type = string
}

variable "ingest_version" {
  type = string
}

variable "analysis_version" {
  type = string
}

variable "min_instances" {
  type    = number
  default = 0
}

variable "max_instances" {
  type    = number
  default = 10
}

variable "ingest_invokers" {
  type    = list(string)
  default = []
}
