data "http" "ipv4" {
  url = "https://api.ipify.org"
}

resource "cloudflare_record" "ipv4" {
  name    = "${data.sops_file.cloudflare_secrets.data["SECRET_DOMAIN"]}"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = chomp(data.http.ipv4.body)
  proxied = true
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "cname_wireguard" {
  name    = "wireguard"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = "${data.sops_file.cloudflare_secrets.data["SECRET_DOMAIN"]}"
  proxied = false
  type    = "CNAME"
  ttl     = 1
}