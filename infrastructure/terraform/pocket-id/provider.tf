terraform {
  backend "s3" {
    bucket       = "terraform"
    key          = "pocket-id/state.tfstate"
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
      version = "1.3.0"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "0.16.0"
    }
    pocketid = {
      source = "Trozz/pocketid"
      version = "0.1.5"
    }
  }
}

provider "bitwarden" {
  access_token = data.sops_file.this.data["BW_PROJECT_TOKEN"]
  experimental {
    embedded_client = true
  }
}

data "bitwarden_secret" "pocketid" {
  key = "pocket-id"
}

provider "pocketid" {
  base_url = "https://oidc.garb.dev"
  api_token  = local.pocketid_secrets["api_key"]
}

locals {
  pocketid_secrets = jsondecode(data.bitwarden_secret.pocketid.value)
}
