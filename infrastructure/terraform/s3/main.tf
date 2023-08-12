data "sops_file" "this" {
  source_file = "secrets.sops.yaml"
}

module "minio" {
  for_each = toset([
    "velero",
    "pgsql"
  ])
  source     = "./minio"
  bucketname = each.value
}
