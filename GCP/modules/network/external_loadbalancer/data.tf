data "google_compute_global_address" "main" {
  name    = var.global_address_name
  project = var.project
}