data "http" "ip_address" {
  url = "https://api64.ipify.org"
}

resource "cloudflare_record" "ip" {
  name    = data.sops_file.cloudflare_secrets.data["SECRET_DOMAIN"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = chomp(data.http.ip_address.response_body)
  proxied = true
  type    = "A"
  ttl     = 1
}

resource "cloudflare_record" "cname_wireguard" {
  name    = "wireguard"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["SECRET_DOMAIN"]
  proxied = false
  type    = "CNAME"
  ttl     = 1
}


resource "cloudflare_record" "mail_txt" {
  name    = data.sops_file.cloudflare_secrets.data["SECRET_DOMAIN"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["SECRET_MX_DOMAIN_TXT_1"]
  type    = "TXT"
  ttl     = 300
}

resource "cloudflare_record" "mail_mx_1" {
  name    = data.sops_file.cloudflare_secrets.data["SECRET_DOMAIN"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["SECRET_MX_DOMAIN_MX_1"]
  type    = "MX"
  ttl     = 300
  priority = 10
}

resource "cloudflare_record" "mail_mx_2" {
  name    = data.sops_file.cloudflare_secrets.data["SECRET_DOMAIN"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["SECRET_MX_DOMAIN_MX_2"]
  type    = "MX"
  ttl     = 300
  priority = 20
}

resource "cloudflare_record" "mail_spf" {
  name    = data.sops_file.cloudflare_secrets.data["SECRET_DOMAIN"]
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["SECRET_MX_DOMAIN_DATA"]
  type    = "TXT"
  ttl     = 1
}

resource "cloudflare_record" "mail_dkey_1" {
  name    = "protonmail._domainkey"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["SECRET_MX_DOMAIN_KEY_1"]
  type    = "CNAME"
  proxied = false
  ttl     = 1
}

resource "cloudflare_record" "mail_dkey_2" {
  name    = "protonmail2._domainkey"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["SECRET_MX_DOMAIN_KEY_2"]
  type    = "CNAME"
  proxied = false
  ttl     = 1
}

resource "cloudflare_record" "mail_dkey_3" {
  name    = "protonmail3._domainkey"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["SECRET_MX_DOMAIN_KEY_3"]
  type    = "CNAME"
  proxied = false
  ttl     = 1
}

resource "cloudflare_record" "mail_dmarc" {
  name    = "_dmarc"
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  value   = data.sops_file.cloudflare_secrets.data["SECRET_MX_DOMAIN_DMARC"]
  type    = "TXT"
  ttl     = 1
}

