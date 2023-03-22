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
      version = "4.2.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
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

data "sops_file" "cloudflare_secrets" {
  source_file = "secrets.sops.yaml"
}

data "cloudflare_zones" "domain" {
  filter {
    name = data.sops_file.cloudflare_secrets.data["SECRET_DOMAIN"]
  }
}
