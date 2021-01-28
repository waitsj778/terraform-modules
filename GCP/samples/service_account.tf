#################################################################
# service_account_sample_enable = true に設定した時モジュールを呼び出す
#################################################################

locals {
  service_account_sample_enable = false

  _sa_conf = local.service_account_sample_enable ? [{ name = "sample" }] : []
}

module "service_account_sample" {
  for_each = { for v in local._sa_conf : v.name => v }
  source   = "../modules/iam/service_account"

  service_account = {
    account_id   = "sample"
    display_name = "module sample"

    roles = [
      "roles/viewer",
      "roles/compute.instanceAdmin.v1"
    ]
  }
}