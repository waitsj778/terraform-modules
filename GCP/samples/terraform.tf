##############################################################
# Terraformのバージョンを固定する
##############################################################

terraform {
  required_version = "= 0.13.4"

  backend "gcs" {
    bucket = ""
    prefix = ""
  }

}

locals {
  projects = {
    prd     = ""
    stg     = ""
    dev     = ""
    }
}