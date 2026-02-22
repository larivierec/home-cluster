terraform {
  backend "s3" {
    bucket = "terraform"
    key    = "s3/s3.tfstate"
    region = "main"


    # endpoints = {
    #   s3 = "https://s3.garb.dev"
    # }

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
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.17.0"
    }
  }
}

provider "onepassword" {
  connect_url   = "https://op.garb.dev"
  connect_token = data.sops_file.this.data["OP_CONNECT_TOKEN"]
}

provider "cloudflare" {
  email   = local.cloudflare_secrets["email"]
  api_key = local.cloudflare_secrets["api_key"]
}

data "onepassword_item" "cloudflare" {
  vault = "Homelab"
  title = "cloudflare"
}

locals {
  cloudflare_secrets = {
    for field in [
      for section in data.onepassword_item.cloudflare.section :
      section if section.label == "credentials"
    ][0].field :
    field.label => field.value
  }
}
