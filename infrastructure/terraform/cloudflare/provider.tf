terraform {
  backend "remote" {
    organization = "larivierec"
    workspaces {
      name = "home-tf"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.9.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.2"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "0.6.1"
    }
  }
}

provider "cloudflare" {
  email   = lookup(local.cloudflare_secrets, "email").text
  api_key = lookup(local.cloudflare_secrets, "cloudflare_api_key").text
}

provider "bitwarden" {
  master_password = data.sops_file.this.data["SECRET_PASSWORD"]
  client_id       = data.sops_file.this.data["SECRET_CLIENT_ID"]
  client_secret   = data.sops_file.this.data["SECRET_CLIENT_SECRET"]
  email           = data.sops_file.this.data["SECRET_EMAIL"]
  server          = "https://vault.bitwarden.com"
}

data "bitwarden_item_login" "cloudflare_secrets" {
  id = "1698e91f-dc8b-494b-bea9-b00a016f98cb"
}

locals {
  cloudflare_secrets = zipmap(
    data.bitwarden_item_login.cloudflare_secrets.field.*.name,
    data.bitwarden_item_login.cloudflare_secrets.field.*
  )
}
