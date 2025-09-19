terraform {
  backend "s3" {
    bucket       = "terraform"
    key          = "tailscale/tailscale.tfstate"
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
    sops = {
      source  = "carlpett/sops"
      version = "1.2.1"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "0.16.0"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.22.0"
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
