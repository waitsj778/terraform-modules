locals {
  _sa_in_fw_list = distinct(flatten([
    for _conf in var.ingress_firewall : _conf.target_service_accounts
  ]))

  _sa_eg_fw_list = distinct(flatten([
    for _conf in var.egress_firewall : _conf.target_service_accounts
  ]))

  _fw_list = distinct(concat(local._sa_in_fw_list, local._sa_eg_fw_list))

}

data "google_service_account" "main" {
  for_each = { for v in local._fw_list : join("-", [v.account_id, v.project]) => v }

  account_id = each.value.account_id
  project    = each.value.project
}