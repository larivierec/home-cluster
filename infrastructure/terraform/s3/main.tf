data "sops_file" "this" {
  source_file = "secrets.sops.yaml"
}

module "cloudflare" {
  source = "./cloudflare"
}

module "minio" {
  for_each   = toset(local.buckets)
  source     = "./minio"
  bucketname = each.value
}

resource "bitwarden_item_login" "this" {
  for_each  = module.minio
  name      = "minio-tf-${each.value.service}"
  username  = each.value.access_key
  password  = each.value.secret_key
  folder_id = "d8947594-b7a8-4553-aad2-ac010149ee32"
  field {
    name = "terraform"
    text = "true"
  }

  field {
    name = "repository"
    text = "larivierec/home-cluster/provision/terraform/s3"
  }
}

locals {
  buckets = [
    "velero",
    "pgsql",
    "thanos"
  ]
}
