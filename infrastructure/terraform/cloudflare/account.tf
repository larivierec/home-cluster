resource "cloudflare_account" "this" {
  name = "garbinc account"
}

resource "cloudflare_r2_bucket" "backup" {
  name       = "nas-backup"
  account_id = cloudflare_account.this.id
  location   = "ENAM"

  lifecycle {
    prevent_destroy = true
  }
}
