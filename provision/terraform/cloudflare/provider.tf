terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.10.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "0.6.3"
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
