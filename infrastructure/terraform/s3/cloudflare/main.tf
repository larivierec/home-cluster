data "cloudflare_accounts" "this" {
  name = "garbinc account"
}

resource "cloudflare_r2_bucket" "backup" {
  name       = "nas-backup"
  account_id = data.cloudflare_accounts.this.accounts[0].id
  location   = "ENAM"

  lifecycle {
    prevent_destroy = true
  }
}
