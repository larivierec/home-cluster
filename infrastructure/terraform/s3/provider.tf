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
      version = "0.7.2"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "0.6.3"
    }
    minio = {
      source  = "aminueza/minio"
      version = "1.17.2"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.12.0"
    }
  }
}

provider "bitwarden" {
  master_password = data.sops_file.this.data["SECRET_PASSWORD"]
  client_id       = data.sops_file.this.data["SECRET_CLIENT_ID"]
  client_secret   = data.sops_file.this.data["SECRET_CLIENT_SECRET"]
  email           = data.sops_file.this.data["SECRET_EMAIL"]
  server          = "https://vault.bitwarden.com"
}

provider "minio" {
  minio_server   = "s3.${lookup(local.cloudflare_secrets, "domain").text}"
  minio_user     = data.bitwarden_item_login.minio_secret.username
  minio_password = data.bitwarden_item_login.minio_secret.password
  minio_ssl      = true
}

provider "cloudflare" {
  email   = lookup(local.cloudflare_secrets, "email").text
  api_key = lookup(local.cloudflare_secrets, "cloudflare_api_key").text
}

data "bitwarden_item_login" "minio_secret" {
  id = "0a39c7b4-2e5d-4afa-8469-aea401037d8b"
}

data "bitwarden_item_login" "cloudflare_secrets" {
  id = "1698e91f-dc8b-494b-bea9-b00a016f98cb"
}

locals {
  cloudflare_secrets = zipmap(
    data.bitwarden_item_login.cloudflare_secrets.field.*.name,
    data.bitwarden_item_login.cloudflare_secrets.field.*
  )
}
