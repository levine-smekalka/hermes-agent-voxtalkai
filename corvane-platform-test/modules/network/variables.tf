variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "cidr" {
  type = string
}

variable "firewall_rules" {
  description = "Ingress allow rules keyed by a stable identifier."
  type = map(object({
    name          = string
    priority      = optional(number, 1000)
    source_ranges = list(string)
    target_tags   = optional(list(string), [])
    protocol      = string
    ports         = optional(list(string), [])
    log           = optional(bool, false)
  }))
  default = {}
}
