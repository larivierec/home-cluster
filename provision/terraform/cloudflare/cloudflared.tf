resource "cloudflare_tunnel" "this" {
  account_id = cloudflare_account.this.id
  name       = "k3s-tunnel"
  secret     = lookup(local.cloudflare_secrets, "cloudflared_pw").text
}
