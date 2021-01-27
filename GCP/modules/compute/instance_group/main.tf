locals {
  _container_config = {
    spec = {
      containers = [
        {
          image = var.instance_template.container_config.image
        }
      ]
      restartPolicy = var.instance_template.container_config.restart_policy
    }
  }

  _autoscaler_config = var.autoscaling != null ? [var.autoscaling] : []
}

resource "google_compute_instance_template" "main" {
  name_prefix  = var.instance_template.name_prefix
  machine_type = var.instance_template.machine_type
  region       = var.instance_template.region
  tags         = var.instance_template.tags

  metadata = {
    google-logging-enabled    = var.instance_template_logging_enabled
    gce-container-declaration = var.instance_template.container_config.enable ? yamlencode(local._container_config) : null
  }

  network_interface {
    subnetwork = var.instance_template.subnetwork

    dynamic "access_config" {
      for_each = var.access_config
      iterator = config
      content {
        nat_ip       = config.value.nat_ip
        network_tier = config.value.network_tier
      }
    }
  }

  service_account {
    email  = var.instance_template.email != null ? data.google_service_account.main[var.instance_template.email].email : null
    scopes = var.instance_template.scopes
  }


  scheduling {
    automatic_restart   = var.instance_template.automatic_restart
    on_host_maintenance = var.instance_template.on_host_maintenance
  }

  disk {
    source_image = var.instance_template.source_image
    disk_size_gb = var.instance_template.disk_size
    auto_delete  = var.instance_template.auto_delete
    boot         = var.instance_template.boot
    disk_type    = var.instance_template.disk_type
    mode         = "READ_WRITE"
  }
}

resource "google_compute_region_instance_group_manager" "main" {
  name               = var.instance_group_manager.name
  base_instance_name = var.instance_group_manager.base_instance_name
  region             = var.instance_group_manager.region
  target_size        = var.instance_group_manager.target_size

  dynamic "named_port" {
    for_each = var.named_port != null ? [
      var.named_port
    ] : []
    iterator = conf

    content {
      name = conf.value.name
      port = conf.value.port
    }
  }

  version {
    instance_template = var.instance_group_manager.template_id
  }

  dynamic "version" {
    for_each = var.target_size
    iterator = conf

    content {
      name              = var.instance_group_manager.version_name
      instance_template = google_compute_instance_template.main.id

      target_size {
        fixed   = conf.value.percent == null ? conf.value.fixed : null
        percent = conf.value.fixed == null ? conf.value.percent : null
      }
    }
  }

  update_policy {
    type                         = var.instance_group_manager.update_policy.type
    minimal_action               = var.instance_group_manager.update_policy.minimal_action
    instance_redistribution_type = var.instance_group_manager.update_policy.instance_redistribution_type
    max_surge_fixed              = var.instance_group_manager.update_policy.max_surge_fixed
    max_unavailable_fixed        = var.instance_group_manager.update_policy.max_unavailable_fixed
    min_ready_sec                = var.instance_group_manager.update_policy.min_ready_sec
  }

  dynamic "auto_healing_policies" {
    for_each = var.auto_healing_policies
    iterator = conf
    content {
      health_check      = conf.value.health_check
      initial_delay_sec = conf.value.initial_delay_sec
    }
  }
}

resource "google_compute_region_autoscaler" "main" {
  for_each = { for v in local._autoscaler_config : v.name => v }

  name   = each.value.name
  region = var.instance_group_manager.region
  target = google_compute_region_instance_group_manager.main.id

  autoscaling_policy {
    max_replicas    = each.value.autoscaling_policy.max_replicas
    min_replicas    = each.value.autoscaling_policy.min_replicas
    cooldown_period = each.value.autoscaling_policy.cooldown_period

    cpu_utilization {
      target = each.value.autoscaling_policy.cpu_utilization_target
    }
  }
}