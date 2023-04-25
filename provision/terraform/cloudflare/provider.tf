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
      version = "4.4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.3.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.2"
    }
  }
}

provider "cloudflare" {
  email   = data.sops_file.cloudflare_secrets.data["SECRET_EMAIL"]
  api_key = data.sops_file.cloudflare_secrets.data["SECRET_CLOUDFLARE_API_KEY"]
}
