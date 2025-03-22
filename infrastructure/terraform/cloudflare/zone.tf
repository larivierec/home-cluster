
data "cloudflare_zone" "default" {
  filter = {
    name = "garb.dev"
  }
}


data "http" "uptimerobot_ipv4" {
  url = "https://uptimerobot.com/inc/files/ips/IPv4.txt"
}

resource "cloudflare_zone_dnssec" "name" {
  zone_id = data.cloudflare_zone.default.zone_id
}

resource "cloudflare_list" "uptimerobot" {
  account_id  = cloudflare_account.this.id
  name        = "uptimerobot"
  kind        = "ip"
  description = "List of UptimeRobot IP Addresses"
}

resource "cloudflare_list_item" "uptimerobot_ipv4_list" {
  for_each   = toset(split("\r\n", chomp(data.http.uptimerobot_ipv4.response_body)))
  account_id = cloudflare_account.this.id
  list_id    = cloudflare_list.uptimerobot.id
  ip         = each.value
}

resource "cloudflare_ruleset" "this" {
  zone_id = data.cloudflare_zone.default.zone_id
  kind    = "zone"
  name    = "WAF rules"
  phase   = "http_request_firewall_custom"

  rules = [{
    action      = "skip"
    description = "allow uptime robot"
    expression  = "(ip.src in $uptimerobot)"
    action_parameters = {
      ruleset = "current"
    }

    logging = {
      enabled = true
    }
    },
    {
      action      = "block"
      description = "block countries"
      expression  = "(ip.geoip.country ne \"US\" and ip.geoip.country ne \"CA\")"
    },
    {
      action      = "block"
      description = "block plex notifications"
      expression  = "(http.host eq \"plex.${data.cloudflare_zone.default.name}\" and http.request.uri.path contains \"/:/eventsource/notifications\")"
  }]
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
