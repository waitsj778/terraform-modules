#########################################################
# network_sample_enable = true に設定した時モジュールを呼び出す
#########################################################

locals {
  network_sample_enable = false

  _network_modules = local.network_sample_enable ? [{ name = "sample" }] : []

  _sa_nw_samples = local.network_sample_enable ? [
    "sample1",
    "sample2"
  ] : []
}

module "network_sample" {
  depends_on = [
    module.sa_network_sample
  ]
  for_each = { for v in local._network_modules : v.name => v }
  source   = "../modules/network/vpc_network"

  vpc_network = "sample"

  subnetwork = [
    {
      name                     = "sample"
      cidr                     = "192.168.10.0/24"
      region                   = "asia-northeast1"
      private_ip_google_access = true
      purpose                  = null
      role                     = null
    }
  ]

  ingress_firewall = [
    {
      name                    = "sample-fw"
      priority                = 1000
      description             = "sample"
      source_service_accounts = []
      source_ranges           = []
      target_service_accounts = [
        {
          account_id = "sample1"
          project    = local.projects[terraform.workspace]
        },
        {
          account_id = "sample2"
          project    = local.projects[terraform.workspace]
        },

      ]
      log_config_metadata = "INCLUDE_ALL_METADATA"
      rules = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
    },
    {
      name                    = "sample-fw2"
      priority                = 1000
      description             = "sample2"
      source_service_accounts = []
      source_ranges           = []
      target_service_accounts = [
        {
          account_id = "sample1"
          project    = local.projects[terraform.workspace]
        },
        {
          account_id = "sample2"
          project    = local.projects[terraform.workspace]
        },

      ]
      log_config_metadata = "INCLUDE_ALL_METADATA"
      rules = [
        {
          protocol = "tcp"
          ports    = ["80", "443"]
        }
      ]
    }


  ]

  egress_firewall = [
    {
      name                    = "deny-all-egress"
      priority                = 65535
      description             = "sample"
      destination_ranges      = ["0.0.0.0/0"]
      target_service_accounts = []
      log_config_metadata     = "EXCLUDE_ALL_METADATA"

      allow_rules = []
      deny_rules = [
        {
          protocol = "all"
          ports    = null
        }
      ]
    },
    {
      name               = "test"
      priority           = 1000
      description        = "sample"
      destination_ranges = ["192.168.10.0/24"]
      target_service_accounts = [
        {
          account_id = "sample1"
          project    = local.projects[terraform.workspace]
        },
        {
          account_id = "sample2"
          project    = local.projects[terraform.workspace]
        },
      ]
      log_config_metadata = null
      allow_rules = [
        {
          protocol = "tcp"
          ports    = null
        }
      ]
      deny_rules = []
    }
  ]
}

module "sa_network_sample" {
  for_each = toset(local._sa_nw_samples)
  source   = "../modules/iam/service_account"

  service_account = {
    account_id   = each.value
    display_name = each.value

    roles = []
  }
}