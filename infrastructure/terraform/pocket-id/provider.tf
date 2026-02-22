terraform {
  backend "s3" {
    bucket = "terraform"
    key    = "pocket-id/state.tfstate"
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
    pocketid = {
      source  = "Trozz/pocketid"
      version = "0.1.7"
    }
  }
}

provider "onepassword" {
  service_account_token = data.sops_file.this.data["OP_SERVICE_ACCOUNT_TOKEN"]
}

data "onepassword_item" "pocketid" {
  vault = "Homelab"
  title = "pocket-id"
}

provider "pocketid" {
  base_url  = "https://oidc.garb.dev"
  api_token = local.pocketid_secrets["api_key"]
}

locals {
  pocketid_secrets = {
    for field in [
      for section in data.onepassword_item.pocketid.section :
      section if section.label == "credentials"
    ][0].field :
    field.label => field.value
  }
}
