resource "cloudflare_account" "this" {
  name = "garbinc account"
  type = "standard"

  settings = {
    enforce_twofactor = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
