terraform {
  backend "remote" {
    organization = "larivierec"
    workspaces {
      name = "home-tailscale-provisioner"
    }
  }

  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "1.1.1"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "0.8.0"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.16.2"
    }
  }
}

provider "bitwarden" {
  master_password = data.sops_file.this.data["SECRET_PASSWORD"]
  client_id       = data.sops_file.this.data["SECRET_CLIENT_ID"]
  client_secret   = data.sops_file.this.data["SECRET_CLIENT_SECRET"]
  email           = data.sops_file.this.data["SECRET_EMAIL"]
  server          = "https://vault.bitwarden.com"
}

provider "tailscale" {
  oauth_client_id     = lookup(local.secrets, "tailscale-clientid").text
  oauth_client_secret = lookup(local.secrets, "tailscale-clientsecret").text
}

data "bitwarden_item_login" "secrets" {
  id = "336e4bd7-6293-48cc-8d5e-b05d01565916"
}

locals {
  secrets = zipmap(
    data.bitwarden_item_login.secrets.field.*.name,
    data.bitwarden_item_login.secrets.field.*
  )
}
