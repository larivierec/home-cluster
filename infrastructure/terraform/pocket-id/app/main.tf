resource "pocketid_client" "web_app" {
  name = "${var.application}-client"
  callback_urls = var.callback_urls
  logout_callback_urls = var.logout_urls
  is_public    = var.is_public
  pkce_enabled = var.pkce_enabled
}