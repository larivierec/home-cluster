provider "github" {
  token = lookup(local.github_secrets, "pat").text
}

provider "bitwarden" {
  master_password = data.sops_file.this.data["SECRET_PASSWORD"]
  client_id       = data.sops_file.this.data["SECRET_CLIENT_ID"]
  client_secret   = data.sops_file.this.data["SECRET_CLIENT_SECRET"]
  email           = data.sops_file.this.data["SECRET_EMAIL"]
  server          = "https://vault.bitwarden.com"
}

data "bitwarden_item_login" "github_secrets" {
  id = "a11107b4-28ef-480c-b195-b05d01565917"
}

data "bitwarden_item_secure_note" "riverbot_private_key" {
  id = "e6b6e351-0627-47f2-aa90-b05d01565917"
}

locals {
  github_secrets = zipmap(
    data.bitwarden_item_login.github_secrets.field.*.name,
    data.bitwarden_item_login.github_secrets.field.*
  )
}
