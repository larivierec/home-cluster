data "sops_file" "this" {
  source_file = "secrets.sops.yaml"
}

module "pocketid" {
  for_each = local.apps
  source = "./app"
  application = each.key
  callback_urls = each.value.callback_urls
  is_public    = each.value.is_public
  pkce_enabled = each.value.pkce_enabled
}

resource "bitwarden_secret" "this" {
  for_each   = module.pocketid
  key        = "pocketid_${each.key}"
  project_id = data.sops_file.this.data["BW_PROJECT_ID"]
  value      = jsonencode({ "client_id" : each.value.client_id, "client_secret" : each.value.client_secret })
  note       = "infrastructure/terraform/pocket-id"
}

locals {
  apps = {
    "change-detection" = {
      callback_urls = [
        "https://changedetection.garb.dev/oauth2/callback",
      ]
      is_public    = false
      pkce_enabled = true
    }
  }
}