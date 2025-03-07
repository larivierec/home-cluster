
data "cloudflare_zone" "default" {
  account_id = cloudflare_account.this.id
  name       = "garb.dev"
}

resource "cloudflare_zone_settings_override" "cloudflare_settings" {
  zone_id = data.cloudflare_zone.default.zone_id
  settings {
    # ssl
    always_use_https = "on"
    ssl              = "strict"

    min_tls_version          = "1.2"
    opportunistic_encryption = "on"
    tls_1_3                  = "zrt"
    automatic_https_rewrites = "on"
    universal_ssl            = "on"

    # site settings
    security_level = "medium"
    brotli         = "on"
    rocket_loader  = "off"

    # network
    http3               = "on"
    ipv6                = "on"
    websockets          = "on"
    pseudo_ipv4         = "off"
    always_online       = "off"
    ip_geolocation      = "on"
    zero_rtt            = "on"
    opportunistic_onion = "on"

    # scrape shield
    email_obfuscation   = "on"
    server_side_exclude = "on"
    hotlink_protection  = "on"
  }
}

data "http" "uptimerobot_ipv4" {
  url = "https://uptimerobot.com/inc/files/ips/IPv4.txt"
}

resource "cloudflare_list" "uptimerobot" {
  account_id  = cloudflare_account.this.id
  name        = "uptimerobot"
  kind        = "ip"
  description = "List of UptimeRobot IP Addresses"

  dynamic "item" {
    for_each = split("\r\n", chomp(data.http.uptimerobot_ipv4.response_body))
    content {
      value {
        ip = item.value
      }
    }
  }
}

resource "cloudflare_ruleset" "this" {
  zone_id = data.cloudflare_zone.default.zone_id
  kind    = "zone"
  name    = "WAF rules"
  phase   = "http_request_firewall_custom"

  rules {
    action      = "skip"
    description = "allow uptime robot"
    expression  = "(ip.src in $uptimerobot)"
    action_parameters {
      ruleset = "current"
    }

    logging {
      enabled = true
    }
  }

  rules {
    action      = "block"
    description = "block countries"
    expression  = "(ip.geoip.country ne \"US\" and ip.geoip.country ne \"CA\")"
  }

  rules {
    action      = "block"
    description = "block plex notifications"
    expression  = "(http.host eq \"plex.${data.cloudflare_zone.default.name}\" and http.request.uri.path contains \"/:/eventsource/notifications\")"
  }
}

# resource "cloudflare_ruleset" "redirect" {
#   zone_id     = data.cloudflare_zone.default.zone_id
#   name        = "gh redirect"
#   description = "Redirects ruleset"
#   kind        = "zone"
#   phase       = "http_request_redirect"

#   rules {
#     action = "redirect"
#     action_parameters {
#       from_value {
#         status_code = 301
#         target_url {
#           value = "https://github.com/larivierec/home-cluster"
#         }
#         preserve_query_string = false
#       }
#     }
#     expression  = "(http.host eq \"garb.dev\") or (http.host eq \"www.garb.dev\")"
#     description = "Redirect root and www to gh"
#     enabled     = true
#   }
# }

resource "cloudflare_zone_dnssec" "ds" {
  zone_id = data.cloudflare_zone.default.zone_id
}
