resource "cloudflare_tunnel" "this" {
  account_id = cloudflare_account.this.id
  name = "k3s-tunnel"
  secret = data.sops_file.cloudflare_secrets.data["SECRET_CLOUDFLARED_PW"]
}

resource "cloudflare_record" "cloudflared" {
  name = "tunnel"
  zone_id = data.cloudflare_zone.domain.zone_id
  value = cloudflare_tunnel.this.cname
  type = "CNAME"
}
