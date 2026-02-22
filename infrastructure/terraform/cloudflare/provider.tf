terraform {
  backend "s3" {
    bucket = "terraform"
    key    = "cloudflare/cloudflare_v5.tfstate"
    region = "main"

    # endpoints = {
    #   s3 = "https://s3.garb.dev"
    # }

    // ref: https://github.com/hashicorp/terraform/issues/36412 and 
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
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.17.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.3.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "~> 3.2.1"
    }
  }
}

provider "cloudflare" {
  email   = local.secrets["email"]
  api_key = local.secrets["api_key"]
}

provider "onepassword" {
  service_account_token = data.sops_file.this.data["OP_SERVICE_ACCOUNT_TOKEN"]
}

data "onepassword_item" "cloudflare" {
  vault = "Homelab"
  title = "cloudflare"
}

locals {
  secrets = {
    for field in [
      for section in data.onepassword_item.cloudflare.section :
      section if section.label == "credentials"
    ][0].field :
    field.label => field.value
  }
}
