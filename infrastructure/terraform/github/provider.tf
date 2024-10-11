provider "github" {
  token = local.github_secrets["pat"]
}

provider "bitwarden" {
  master_password = data.sops_file.this.data["SECRET_PASSWORD"]
  client_id       = data.sops_file.this.data["SECRET_CLIENT_ID"]
  client_secret   = data.sops_file.this.data["SECRET_CLIENT_SECRET"]
  email           = data.sops_file.this.data["SECRET_EMAIL"]
  server          = "https://vault.bitwarden.com"
  experimental {
    embedded_client = true
  }
}

provider "bitwarden" {
  alias        = "bws"
  access_token = data.sops_file.this.data["BW_PROJECT_TOKEN"]
  experimental {
    embedded_client = true
  }
}

data "bitwarden_secret" "this" {
  provider = bitwarden.bws
  id       = "b283f0a4-85da-4ce3-a5fa-b20400d83993"
}

data "bitwarden_secret" "github" {
  provider = bitwarden.bws
  id       = "4c93fe22-dd57-4d4d-96b2-b20600132b47"
}

# data "bitwarden_item_login" "github_secrets" {
#   id = "a11107b4-28ef-480c-b195-b05d01565917"
# }

# data "bitwarden_item_secure_note" "riverbot_private_key" {
#   id = "e6b6e351-0627-47f2-aa90-b05d01565917"
# }

locals {
  # github_secrets = zipmap(
  #   data.bitwarden_item_login.github_secrets.field.*.name,
  #   data.bitwarden_item_login.github_secrets.field.*
  # )
  github_secrets = jsondecode(data.bitwarden_secret.github.value)
  secrets        = jsondecode(data.bitwarden_secret.this.value)
}
