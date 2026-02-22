data "sops_file" "this" {
  source_file = "secrets.sops.yaml"
}

module "pocketid" {
  for_each      = local.apps
  source        = "./app"
  application   = each.key
  callback_urls = each.value.callback_urls
  logout_urls   = each.value.logout_callback_urls
  is_public     = each.value.is_public
  pkce_enabled  = each.value.pkce_enabled
}

data "onepassword_vault" "this" {
  name = "Homelab"
}

resource "onepassword_item" "this" {
  for_each = module.pocketid
  vault    = data.onepassword_vault.this.uuid
  title    = "pocketid_${each.key}"
  category = "login"
  section_map = {
    "credentials" = {
      field_map = {
        "client_id" = {
          type  = "STRING"
          value = each.value.client_id
        }
        "client_secret" = {
          type  = "CONCEALED"
          value = each.value.client_secret
        }
      }
    }
    "metadata" = {
      field_map = {
        "source" = {
          type  = "STRING"
          value = "infrastructure/terraform/pocket-id"
        }
      }
    }
  }
}

locals {
  apps = {
    "change-detection" = {
      callback_urls = [
        "https://changedetection.garb.dev/oauth2/callback",
      ]
      logout_callback_urls = [
        "https://changedetection.garb.dev/oauth2/logout",
      ]
      is_public    = false
      pkce_enabled = true
    }
  }
}
