
output "access_key" {
  value = minio_iam_service_account.this.access_key
}

output "secret_key" {
  value     = minio_iam_service_account.this.secret_key
  sensitive = true
}
