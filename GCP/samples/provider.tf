##############################################################
# プロバイダーのバージョンを固定する
##############################################################

provider "google" {
  version = "= 3.34.0"
  project = local.projects[terraform.workspace]
}

provider "google-beta" {
  version = "= 3.34.0"
  project = local.projects[terraform.workspace]
}

locals {
  projects = {
    prd     = ""
    stg     = ""
    dev     = ""
  }
}