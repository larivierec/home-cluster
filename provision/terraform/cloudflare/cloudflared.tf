resource "cloudflare_tunnel" "this" {
  account_id = cloudflare_account.this.id
  name       = "k3s-tunnel"
  secret     = lookup(local.cloudflare_secrets, "cloudflared_pw").text
}

resource "cloudflare_record" "cloudflared" {
  name    = "tunnel"
  zone_id = data.cloudflare_zone.default.zone_id
  value   = cloudflare_tunnel.this.cname
  type    = "CNAME"
}
