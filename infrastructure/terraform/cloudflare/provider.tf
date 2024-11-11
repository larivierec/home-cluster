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
      version = "4.45.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.1.1"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "0.11.1"
    }
  }
}

provider "cloudflare" {
  email   = local.secrets["email"]
  api_key = local.secrets["api_key"]
}

provider "bitwarden" {
  access_token = data.sops_file.this.data["BW_PROJECT_TOKEN"]
  experimental {
    embedded_client = true
  }
}

data "bitwarden_secret" "cloudflare" {
  key = "cloudflare"
}

locals {
  secrets = jsondecode(data.bitwarden_secret.cloudflare.value)
}
