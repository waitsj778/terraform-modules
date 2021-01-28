resource "google_service_account" "main" {
  account_id   = var.service_account.account_id
  display_name = var.service_account.display_name
}

resource "google_project_iam_member" "main" {
  for_each = toset(var.service_account.roles)

  role   = each.value
  member = join(":", ["serviceAccount", google_service_account.main.email])
}

resource "google_service_account_iam_member" "main" {
  for_each = { for v in var.service_account.bindings : join("-", [v.member, v.role]) => v }

  service_account_id = google_service_account.main.name
  role               = each.value.role
  member             = each.value.member
}