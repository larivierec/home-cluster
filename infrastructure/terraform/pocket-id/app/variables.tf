variable "application" {
  type = string
}

variable "callback_urls" {
  type = list(string)
}

variable "is_public" {
  type    = bool
  default = false
}

variable "pkce_enabled" {
  type    = bool
  default = true
}
