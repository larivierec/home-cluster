resource "cloudflare_account" "this" {
  name              = "garbinc account"
  enforce_twofactor = true
  lifecycle {
    prevent_destroy = true
  }
}
