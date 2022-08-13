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
      version = "3.21.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.0.1"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.7.1"
    }
  }
}

data "sops_file" "cloudflare_secrets" {
  source_file = "secrets.sops.yaml"
}

provider "cloudflare" {
  email   = data.sops_file.cloudflare_secrets.data["SECRET_EMAIL"]
  api_key = data.sops_file.cloudflare_secrets.data["SECRET_CLOUDFLARE_API_KEY"]
}

data "cloudflare_zones" "domain" {
  filter {
    name = data.sops_file.cloudflare_secrets.data["SECRET_DOMAIN"]
  }
}
