variable "vpc_network" {
  type = string
}

variable "vpc_network_delete_default_routes_on_create" {
  type    = bool
  default = false
}

variable "subnetwork" {
  type = list(object({
    name                     = string
    cidr                     = string
    region                   = string
    purpose                  = string
    role                     = string
    private_ip_google_access = bool
  }))
}

variable "ingress_firewall" {
  type = list(object({
    name                    = string
    priority                = number
    description             = string
    source_service_accounts = list(string)
    source_ranges           = list(string)
    target_service_accounts = list(object({
      account_id = string
      project    = string
    }))
    log_config_metadata = string

    rules = list(object({
      protocol = string
      ports    = list(string)
    }))
  }))
}

variable "egress_firewall" {
  type = list(object({
    name               = string
    priority           = number
    description        = string
    destination_ranges = list(string)
    target_service_accounts = list(object({
      account_id = string
      project    = string
    }))
    log_config_metadata = string

    allow_rules = list(object({
      protocol = string
      ports    = list(string)
    }))

    deny_rules = list(object({
      protocol = string
      ports    = list(string)
    }))
  }))
}