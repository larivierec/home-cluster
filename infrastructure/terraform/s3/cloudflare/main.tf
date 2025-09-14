data "cloudflare_account" "this" {
  filter = {
    name = "garbinc account"
  }
}

resource "cloudflare_r2_bucket" "backup" {
  account_id    = data.cloudflare_account.this.account_id
  name          = "nas-backup"
  location      = "ENAM"
  storage_class = "Standard"
  lifecycle {
    prevent_destroy = true
  }
}
