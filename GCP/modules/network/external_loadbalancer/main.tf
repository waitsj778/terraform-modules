resource "google_compute_backend_service" "main" {
  provider = google-beta

  name                  = var.backend_service.name
  protocol              = var.backend_service.protocol
  load_balancing_scheme = var.backend_service.load_balancing_scheme

  dynamic "circuit_breakers" {
    for_each = var.backend_service.load_balancing_scheme == "INTERNAL_SELF_MANAGED" ? var.backend_service.circuit_breakers : []
    iterator = conf

    content {
      max_requests_per_connection = conf.value.max_requests_per_connection
      max_connections             = conf.value.max_connections
      max_pending_requests        = conf.value.max_pending_requests
      max_retries                 = conf.value.max_retries

      dynamic "connect_timeout" {
        for_each = conf.value.connect_timeout
        iterator = timeout

        content {
          seconds = timeout.value.seconds
          nanos   = timeout.value.nanos
        }
      }
    }
  }

  health_checks = var.backend_service.health_checks

  backend {
    group                        = var.backend_service.group
    balancing_mode               = var.backend_service_balancing_mode
    capacity_scaler              = var.backend_service_capacity_scaler
    max_connections              = var.backend_service_balancing_mode == "UTILIZATION" || var.backend_service_balancing_mode == "CONNECTION" ? var.backend_service_max_connections : null
    max_connections_per_endpoint = var.backend_service_balancing_mode == "UTILIZATION" || var.backend_service_balancing_mode == "CONNECTION" ? var.backend_service_max_connections_per_endpoint : null
    max_rate                     = var.backend_service_balancing_mode == "RATE" || var.backend_service_balancing_mode == "UTILIZATION" ? var.backend_service_max_rate : null
    max_rate_per_instance        = var.backend_service_balancing_mode == "RATE" || var.backend_service_balancing_mode == "UTILIZATION" ? var.backend_service_max_rate_per_instance : null
    max_rate_per_endpoint        = var.backend_service_balancing_mode == "RATE" || var.backend_service_balancing_mode == "UTILIZATION" ? var.backend_service_max_rate_per_endpoint : null
    max_utilization              = var.backend_service_balancing_mode == "UTILIZATION" ? var.backend_service_max_utilization : null
  }
  security_policy = var.security_policy != null ? join("/", [
    "projects", var.project, "global/securityPolicies", var.security_policy
  ]) : null
}

resource "google_compute_target_https_proxy" "main" {
  name          = var.https_proxy.name
  url_map       = google_compute_url_map.main.id
  quic_override = var.quic_override
  ssl_certificates = [
    google_compute_managed_ssl_certificate.main.id
  ]
  ssl_policy = var.ssl_policy
}

resource "google_compute_managed_ssl_certificate" "main" {
  provider = google-beta

  name = var.managed_ssl_certificate.name
  type = "MANAGED"
  managed {
    domains = var.managed_ssl_certificate.domains
  }
}

resource "google_compute_url_map" "main" {
  name            = var.url_map.name
  default_service = google_compute_backend_service.main.id
}

resource "google_compute_global_forwarding_rule" "main" {
  target = google_compute_target_https_proxy.main.id

  name       = var.forwarding_rule.name
  port_range = var.forwarding_rule.port_range
  ip_address = data.google_compute_global_address.main.address
}