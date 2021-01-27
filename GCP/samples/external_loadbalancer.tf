##############################################################
# loadbalancer_sample_enable = true に設定した時モジュールを呼び出す
##############################################################

locals {
  loadbalancer_sample_enable = false

  _loadbalancer_conf = local.loadbalancer_sample_enable ? [{ name = "sample" }] : []
}

module "loadbalancer_sample" {
  for_each = { for v in local._loadbalancer_conf : v.name => v }
  source   = "../modules/network/external_loadbalancer"

  global_address_name = ""

  project = local.projects[terraform.workspace]
  backend_service = {
    name                  = "sample"
    protocol              = null
    health_checks         = []
    group                 = module.loadbalancer_sample_instance_group["sample"].instance_group
    load_balancing_scheme = "EXTERNAL"
  }

  http_health_check = [
    {
      port_name    = null
      host         = null
      request_path = null
      response     = null
      proxy_header = null
      port         = 80
    }
  ]

  url_map = {
    name = "sample"
  }

  https_proxy = {
    name = "sample"
  }

  forwarding_rule = {
    name       = "sample"
    port_range = "443"
  }

  managed_ssl_certificate = {
    name    = "sample"
    domains = ["sslcert.tf-test.club."]
  }
}

module "loadbalancer_sample_instance_group" {
  for_each = { for v in local._loadbalancer_conf : v.name => v }
  source   = "../modules/compute/instance_group"

  instance_template = {
    name_prefix         = "sample"
    labels              = null
    tags                = []
    machine_type        = "f1-micro"
    subnetwork          = "default"
    region              = "asia-northeast1"
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    source_image        = "ubuntu-os-cloud/ubuntu-2004-lts"
    disk_size           = 20
    disk_type           = "pd-standard"
    boot                = true
    auto_delete         = true
    mode                = "READ_WRITE"
    email               = null
    scopes              = []
    container_config = {
      enable         = false
      image          = "gcr.io/google-samples/hello-app:1.0"
      restart_policy = "Always"
    }
  }

  instance_group_manager = {
    name               = "sample"
    base_instance_name = "sample"
    region             = "asia-northeast1"
    target_size        = 1
    version_name       = "sample"

    update_policy = {
      type                         = "PROACTIVE"
      instance_redistribution_type = "PROACTIVE"
      minimal_action               = "REPLACE"
      max_surge_fixed              = 3
      max_unavailable_fixed        = 0
      min_ready_sec                = 50
    }
  }

  autoscaling = {
    name = "sample"
    autoscaling_policy = {
      max_replicas           = 5
      min_replicas           = 1
      cooldown_period        = 60
      cpu_utilization_target = 0.5
    }
  }
}