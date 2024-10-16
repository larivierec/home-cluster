terraform {
  backend "remote" {
    organization = "larivierec"
    workspaces {
      name = "home-s3-provisioner"
    }
  }

  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "1.1.1"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "0.10.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "2.5.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.44.0"
    }
  }
}

provider "bitwarden" {
  alias           = "legacy"
  master_password = data.sops_file.this.data["SECRET_PASSWORD"]
  client_id       = data.sops_file.this.data["SECRET_CLIENT_ID"]
  client_secret   = data.sops_file.this.data["SECRET_CLIENT_SECRET"]
  email           = data.sops_file.this.data["SECRET_EMAIL"]
  server          = "https://vault.bitwarden.com"
  experimental {
    embedded_client = true
  }
}

provider "bitwarden" {
  access_token = data.sops_file.this.data["BW_PROJECT_TOKEN"]
  experimental {
    embedded_client = true
  }
}

provider "minio" {
  minio_server   = "s3.garb.dev"
  minio_user     = local.minio_secrets["user"]
  minio_password = local.minio_secrets["password"]
  minio_ssl      = true
}

provider "cloudflare" {
  email   = local.cloudflare_secrets["email"]
  api_key = local.cloudflare_secrets["api_key"]
}

data "bitwarden_secret" "minio" {
  id = "19d75ac1-1526-44c1-b8d3-b20400d83107"
}

data "bitwarden_secret" "cloudflare" {
  id = "cabc2165-4ca7-4bb9-871e-b20400d82e54"
}

locals {
  cloudflare_secrets = jsondecode(data.bitwarden_secret.cloudflare.value)
  minio_secrets      = jsondecode(data.bitwarden_secret.minio.value)
}
