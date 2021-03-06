resource "cloudflare_zone_settings_override" "cloudflare_settings" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  settings {
    # ssl
    always_use_https = "on"
    ssl = "strict"
    
    min_tls_version = "1.2"
    opportunistic_encryption = "on"
    tls_1_3 = "zrt"
    automatic_https_rewrites = "on"
    universal_ssl = "on"
    
    # site settings
    security_level = "medium"
    brotli = "on"
    minify {
      css = "on"
      js = "on"
      html = "on"
    }
    rocket_loader = "on"

    # network
    http3 = "off"
    ipv6 = "on"
    websockets = "on"
    pseudo_ipv4 = "off"
    always_online = "off"
    ip_geolocation = "on"
    zero_rtt = "on"
    opportunistic_onion = "on"

    # scrape shield
    email_obfuscation = "on"
    server_side_exclude = "on"
    hotlink_protection = "on"
  }
}

resource "cloudflare_filter" "block_bots" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  expression = "(cf.client.bot)"
}

resource "cloudflare_filter" "block_countries" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  expression = "(ip.geoip.country ne \"US\" and ip.geoip.country ne \"CA\")"
}

resource "cloudflare_firewall_rule" "block_countries" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  filter_id = cloudflare_filter.block_countries.id
  action = "block"
}

resource "cloudflare_firewall_rule" "block_bots" {
  zone_id = lookup(data.cloudflare_zones.domain.zones[0], "id")
  filter_id = cloudflare_filter.block_bots.id
  action = "block"
}
