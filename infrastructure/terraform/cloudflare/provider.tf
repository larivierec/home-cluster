terraform {
  backend "s3" {
    bucket       = "terraform"
    key          = "cloudflare/cloudflare_v5.tfstate"
    region       = "main"
    use_lockfile = true

    endpoints = {
      s3 = "https://s3.garb.dev"
    }

    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.11.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.3.0"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "0.16.0"
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
