resource "cloudflare_account" "this" {
  name = "garbinc account"

  settings = {
    enforce_twofactor = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
