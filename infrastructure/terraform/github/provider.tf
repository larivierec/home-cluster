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
  id = "530607a4-a16d-4fd9-90e0-b00a016fb4b3"
}

locals {
  github_secrets = zipmap(
    data.bitwarden_item_login.github_secrets.field.*.name,
    data.bitwarden_item_login.github_secrets.field.*
  )
}
