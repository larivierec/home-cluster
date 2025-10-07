terraform {
  backend "s3" {
    bucket       = "terraform"
    key          = "github/github.tfstate"
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
    github = {
      source  = "integrations/github"
      version = "< 6.7"
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
