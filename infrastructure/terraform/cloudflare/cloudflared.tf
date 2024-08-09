resource "cloudflare_tunnel" "this" {
  account_id = cloudflare_account.this.id
  name       = "k3s-tunnel"
  secret     = lookup(local.cloudflare_secrets, "cloudflared_pw").text
}

resource "cloudflare_record" "tunnel-ingress" {
  name    = "ingress"
  type    = "CNAME"
  zone_id = data.cloudflare_zone.default.zone_id
  proxied = true
  content = cloudflare_tunnel.this.cname
  comment = "Created via Terraform"
}
