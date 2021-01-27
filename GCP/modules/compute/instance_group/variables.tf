variable "instance_template" {
  type = object({
    name_prefix         = string
    machine_type        = string
    subnetwork          = string
    region              = string
    tags                = list(string)
    automatic_restart   = bool
    on_host_maintenance = string
    source_image        = string
    disk_size           = number
    disk_type           = string
    auto_delete         = bool
    boot                = bool
    mode                = string
    email               = string
    scopes              = list(string)
    container_config = object({
      enable         = bool
      image          = string
      restart_policy = string
    })
  })
}

variable "instance_group_manager" {
  type = object({
    name               = string
    base_instance_name = string
    region             = string
    target_size        = string
    version_name       = string
    template_id        = string

    update_policy = object({
      type                         = string
      minimal_action               = string
      instance_redistribution_type = string
      max_surge_fixed              = number
      max_unavailable_fixed        = number
      min_ready_sec                = number
    })
  })
}

variable "auto_healing_policies" {
  type = list(object({
    health_check      = string
    initial_delay_sec = number
  }))

  default = []
}

variable "access_config" {
  type = list(object({
    nat_ip       = string
    network_tier = string
  }))

  default = []
}

variable "target_size" {
  type = list(object({
    fixed   = number
    percent = number
  }))

  default = []
}

variable "instance_template_logging_enabled" {
  type    = bool
  default = true
}

variable "project" {
  type    = string
  default = null
}

variable "named_port" {
  type = object({
    name = string
    port = number
  })
  default = null
}

variable "autoscaling" {
  type = object({
    name = string
    autoscaling_policy = object({
      max_replicas    = number
      min_replicas    = number
      cooldown_period = number

      cpu_utilization_target = number
    })
  })
  default = null
}