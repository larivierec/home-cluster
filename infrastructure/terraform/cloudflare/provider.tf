terraform {
  backend "remote" {
    organization = "larivierec"
    workspaces {
      name = "home-cloudflare-provisioner"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.40.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.4"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.1.1"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "0.8.1"
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
  id = "4c5c42aa-0951-4950-974b-b05d01565917"
}

locals {
  cloudflare_secrets = zipmap(
    data.bitwarden_item_login.cloudflare_secrets.field.*.name,
    data.bitwarden_item_login.cloudflare_secrets.field.*
  )
}
