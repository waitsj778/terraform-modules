variable "global_address_name" {
  type = string
}

variable "backend_service" {
  type = object({
    name                  = string
    protocol              = string
    health_checks         = list(string)
    group                 = string
    load_balancing_scheme = string
  })
}

variable "managed_ssl_certificate" {
  type = object({
    name    = string
    domains = list(string)
  })
}

variable "http_health_check" {
  type = list(object({
    port_name    = string
    host         = string
    request_path = string
    response     = string
    proxy_header = string
    port         = number
  }))
  default = []
}

variable "https_health_check" {
  type = list(object({
    host         = string
    request_path = string
    response     = string
    port         = string
    port_name    = string
    proxy_header = string
  }))
  default = []
}

variable "url_map" {
  type = object({
    name = string
  })
}

variable "https_proxy" {
  type = object({
    name = string
  })
}

variable "forwarding_rule" {
  type = object({
    name       = string
    port_range = string
  })
}


########################################
# option configuration
########################################
variable "ssl_policy" {
  type    = string
  default = null
}

variable "quic_override" {
  type    = string
  default = "NONE"
}

variable "backend_service_balancing_mode" {
  type    = string
  default = "UTILIZATION"
}

variable "backend_service_capacity_scaler" {
  type    = number
  default = 1
}

variable "backend_service_max_connections" {
  type    = number
  default = null
}

variable "backend_service_max_connections_per_endpoint" {
  type    = number
  default = null
}

variable "backend_service_max_rate_per_endpoint" {
  type    = number
  default = null
}

variable "backend_service_max_rate_per_instance" {
  type    = number
  default = null
}
variable "backend_service_max_rate" {
  type    = number
  default = null
}

variable "backend_service_max_utilization" {
  type    = number
  default = null
}

variable "project" {
  type = string
}

variable "security_policy" {
  type    = string
  default = null
}