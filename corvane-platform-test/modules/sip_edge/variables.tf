variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zones" {
  type = list(string)
}

variable "name" {
  type    = string
  default = "sip-edge"
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "image" {
  type    = string
  default = "debian-cloud/debian-12"
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
