variable "service_account" {
  type = object({
    account_id   = string
    display_name = string

    roles = list(string)
    bindings = list(object({
      role   = string
      member = string
    }))
  })
}