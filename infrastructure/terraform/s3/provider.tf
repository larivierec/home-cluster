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
      version = "1.0.0"
    }
    bitwarden = {
      source  = "maxlaverse/bitwarden"
      version = "0.8.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "2.4.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.38.0"
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
  minio_server   = "s3.${"garb.dev"}"
  minio_user     = data.bitwarden_item_login.minio_secret.username
  minio_password = data.bitwarden_item_login.minio_secret.password
  minio_ssl      = true
}

provider "cloudflare" {
  email   = lookup(local.cloudflare_secrets, "email").text
  api_key = lookup(local.cloudflare_secrets, "cloudflare_api_key").text
}

data "bitwarden_item_login" "minio_secret" {
  id = "b7e7c4fc-4d81-4f12-8652-b05d01565916"
}

data "bitwarden_item_login" "cloudflare_secrets" {
  id = "4c5c42aa-0951-4950-974b-b05d01565917"
}

locals {
  cloudflare_secrets = zipmap(
    data.bitwarden_item_login.cloudflare_secrets.field.*.name,
    data.bitwarden_item_login.cloudflare_secrets.field.*
  )
}
