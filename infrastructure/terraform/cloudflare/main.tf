module "dns_records" {
  source = "./dns"
  providers = {
    cloudflare = cloudflare
  }

  zone = { id = data.cloudflare_zone.default.id, name = data.cloudflare_zone.default.name }

  a_records = {
    # make the root domain target self, allowing you to redirect it
    # see zone.tf redirect rule
    "garb.dev"      = { ip = "192.0.2.1", ttl = "1", proxied = true },
    "ipv4.garb.dev" = { ip = "${data.http.ip_address.response_body}", ttl = "1", proxied = true }
  }

  cname_records = {
    "sig1._domainkey" = { cname = nonsensitive(lookup(local.cloudflare_secrets, "DOMAIN_KEY_APPLE").text), ttl = "3600", proxied = false },
    "www"             = { cname = "garb.dev", ttl = "1", proxied = true }
  }

  mx_records = {
    "garb.dev" = {
      ttl = "3600"
      records = [
        { priority = 10, address = "mx01.mail.icloud.com." },
        { priority = 10, address = "mx02.mail.icloud.com." },
      ]
    }
  }

  txt_records = {
    "garb.dev" = { records = [
      "apple-domain=dPAmcbw67V29ieeV",
      "v=spf1 include:icloud.com ~all",
    ], ttl = "3600" },
    "_dmarc" = { records = ["v=DMARC1; p=quarantine"], ttl = "1" },
  }
}

data "http" "ip_address" {
  url = "https://ddns.garb.dev/v1/get"
}

data "sops_file" "this" {
  source_file = "secrets.sops.yaml"
}
