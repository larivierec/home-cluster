variable "a_records" {
  type = map(object({
    records = list(object({
      ip      = string
      ttl     = string
      proxied = bool
    }))
  }))
  default = {}
}

variable "cname_records" {
  type    = map(any)
  default = {}
}

variable "mx_records" {
  type    = map(any)
  default = {}
}

variable "txt_records" {
  type    = map(any)
  default = {}
}

variable "zone" {
  type = map(any)
}
