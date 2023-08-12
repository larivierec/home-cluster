resource "cloudflare_account" "this" {
  name = "garbinc account"

  lifecycle {
    prevent_destroy = true
  }
}
