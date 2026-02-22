terraform {
  backend "s3" {
    bucket = "terraform"
    key    = "tailscale/tailscale.tfstate"
    region = "main"


    endpoints = {
      s3 = "http://192.168.1.3:9000"
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
      version = "1.3.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 3.2.1"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.28.0"
    }
  }
}

provider "onepassword" {
  service_account_token = data.sops_file.this.data["OP_SERVICE_ACCOUNT_TOKEN"]
}

provider "tailscale" {
  oauth_client_id     = local.tailscale_secret["clientid"]
  oauth_client_secret = local.tailscale_secret["clientsecret"]
}

data "onepassword_item" "tailscale" {
  vault = "Homelab"
  title = "tailscale"
}

locals {
  tailscale_secret = {
    for field in [
      for section in data.onepassword_item.tailscale.section :
      section if section.label == "credentials"
    ][0].field :
    field.label => field.value
  }
}
