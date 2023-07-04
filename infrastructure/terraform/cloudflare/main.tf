module "dns_records" {
  source = "./dns"
  providers = {
    cloudflare = cloudflare
  }

  zone = { id = data.cloudflare_zone.default.id, name = data.cloudflare_zone.default.name }

  a_records = {
    nonsensitive(lookup(local.cloudflare_secrets, "domain").text) = { ip = "${data.http.ip_address.response_body}", ttl = "1", proxied = true }
  }

  cname_records = {
    "wireguard"              = { cname = nonsensitive(lookup(local.cloudflare_secrets, "domain").text), ttl = "1", proxied = false },
    "protonmail._domainkey"  = { cname = nonsensitive(lookup(local.cloudflare_secrets, "DOMAIN_KEY_1").text), ttl = "1", proxied = false },
    "protonmail2._domainkey" = { cname = nonsensitive(lookup(local.cloudflare_secrets, "DOMAIN_KEY_2").text), ttl = "1", proxied = false },
    "protonmail3._domainkey" = { cname = nonsensitive(lookup(local.cloudflare_secrets, "DOMAIN_KEY_3").text), ttl = "1", proxied = false },
  }

  mx_records = {
    nonsensitive(lookup(local.cloudflare_secrets, "domain").text) = {
      ttl = "300"
      records = [
        { priority = 10, address = nonsensitive(lookup(local.cloudflare_secrets, "MX_1").text) },
        { priority = 20, address = nonsensitive(lookup(local.cloudflare_secrets, "MX_2").text) },
      ]
    }
  }

  txt_records = {
    nonsensitive(lookup(local.cloudflare_secrets, "domain").text) = { records = [
      nonsensitive(lookup(local.cloudflare_secrets, "MX_1_TXT").text),
      nonsensitive(lookup(local.cloudflare_secrets, "DOMAIN_DATA").text),
    ], ttl = "300" },
    "_dmarc" = { records = [nonsensitive(lookup(local.cloudflare_secrets, "DOMAIN_DMARC").text)], ttl = "1" },
  }
}

data "http" "ip_address" {
  url = "https://ddns.${lookup(local.cloudflare_secrets, "domain").text}/v1/get"
}

data "sops_file" "this" {
  source_file = "secrets.sops.yaml"
}
