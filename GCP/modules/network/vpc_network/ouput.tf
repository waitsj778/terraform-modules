output "network_self_link" {
  value = google_compute_network.main.self_link
}

output "network_name" {
  value = google_compute_network.main.name
}

output "network_id" {
  value = google_compute_network.main.id
}

output "subnetwork_self_link" {
  value = { for v in google_compute_subnetwork.main : v.name => v.self_link }
}

output "subnetwork_name" {
  value = { for v in google_compute_subnetwork.main : v.name => v.name }
}

output "subnetwork_id" {
  value = { for v in google_compute_subnetwork.main : v.name => v.id }
}