resource "cloudflare_tunnel" "this" {
  account_id = cloudflare_account.this.id
  name = "k3s-tunnel"
  secret = data.sops_file.cloudflare_secrets.data["SECRET_CLOUDFLARED_PW"]
}
