locals {
  _email = var.instance_template.email != null ? [var.instance_template.email] : []
}

data "google_service_account" "main" {
  for_each   = toset(local._email)
  account_id = each.value
  project    = var.project
}