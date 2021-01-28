resource "google_compute_network" "main" {
  name                            = var.vpc_network
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
  delete_default_routes_on_create = var.vpc_network_delete_default_routes_on_create
}

resource "google_compute_subnetwork" "main" {
  provider = google-beta
  for_each = { for v in var.subnetwork : v.name => v }

  name          = each.value.name
  ip_cidr_range = each.value.cidr
  network       = google_compute_network.main.self_link
  region        = each.value.region

  private_ip_google_access = each.value.private_ip_google_access
  purpose                  = each.value.purpose
  role                     = each.value.role
}

resource "google_compute_firewall" "ingress_main" {
  for_each = { for v in var.ingress_firewall : v.name => v }

  name                    = each.value.name
  direction               = "INGRESS"
  priority                = each.value.priority
  description             = each.value.description
  network                 = google_compute_network.main.self_link
  source_service_accounts = each.value.source_service_accounts
  source_ranges           = each.value.source_ranges
  target_service_accounts = [
    for v in each.value.target_service_accounts : data.google_service_account.main[join("-", [v.account_id, v.project])].email
  ]

  dynamic "allow" {
    for_each = each.value.rules
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "log_config" {
    for_each = each.value.log_config_metadata != null ? [{
      metadata = each.value.log_config_metadata
    }] : []
    iterator = conf

    content {
      metadata = conf.value.metadata
    }
  }
}

resource "google_compute_firewall" "egress_main" {
  for_each = { for v in var.egress_firewall : v.name => v }

  name               = each.value.name
  direction          = "EGRESS"
  priority           = each.value.priority
  description        = each.value.description
  network            = google_compute_network.main.self_link
  destination_ranges = each.value.destination_ranges
  target_service_accounts = [
    for v in each.value.target_service_accounts : data.google_service_account.main[join("-", [v.account_id, v.project])].email
  ]

  dynamic "allow" {
    for_each = each.value.allow_rules
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  dynamic "deny" {
    for_each = each.value.deny_rules
    content {
      protocol = deny.value.protocol
      ports    = deny.value.ports
    }
  }

  dynamic "log_config" {
    for_each = each.value.log_config_metadata != null ? [{
      metadata = each.value.log_config_metadata
    }] : []
    iterator = conf

    content {
      metadata = conf.value.metadata
    }
  }
}