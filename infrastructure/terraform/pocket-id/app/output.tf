output "client_id" {
  value = pocketid_client.web_app.id
}

output "client_secret" {
  value     = pocketid_client.web_app.client_secret
  sensitive = true
}