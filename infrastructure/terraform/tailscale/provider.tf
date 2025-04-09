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
      version = "1.2.0"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "0.13.5"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.19.0"
    }
  }
}

provider "bitwarden" {
  access_token = data.sops_file.this.data["BW_PROJECT_TOKEN"]
  experimental {
    embedded_client = true
  }
}

provider "tailscale" {
  oauth_client_id     = local.tailscale_secret["clientid"]
  oauth_client_secret = local.tailscale_secret["clientsecret"]
}

data "bitwarden_secret" "tailscale" {
  key = "tailscale"
}

locals {
  tailscale_secret = jsondecode(data.bitwarden_secret.tailscale.value)
}
