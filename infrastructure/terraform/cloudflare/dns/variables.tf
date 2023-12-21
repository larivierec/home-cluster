variable "a_records" {
  type    = map(any)
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
