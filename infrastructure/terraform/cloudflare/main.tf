module "dns_records" {
  source = "./dns"
  providers = {
    cloudflare = cloudflare
  }

  zone = {
    id   = cloudflare_zone.default.id,
    name = cloudflare_zone.default.name
  }

  a_records = {
    "garb.dev" = { ip = "192.0.2.1", ttl = "1", proxied = true }
  }

  cname_records = {
    "sig1._domainkey" = { cname = nonsensitive(local.secrets["DOMAIN_KEY_APPLE"]), ttl = "3600", proxied = false },
    "www"             = { cname = "garb.dev", ttl = "1", proxied = true }
    "wg"              = { cname = "ip.garb.dev", ttl = "1", proxied = false }
  }

  mx_records = {
    "garb.dev" = {
      ttl = "3600"
      records = [
        { priority = 10, address = "mx01.mail.icloud.com" },
        { priority = 10, address = "mx02.mail.icloud.com" },
      ]
    }
  }

  txt_records = {
    "garb.dev" = { records = [
      "\"apple-domain=dPAmcbw67V29ieeV\"",
      "\"v=spf1 include:icloud.com ~all\"",
    ], ttl = "3600" },
    "_dmarc" = { records = ["\"v=DMARC1; p=quarantine; rua=mailto:baee06f019b04b0cacb868a9de6a7ade@dmarc-reports.cloudflare.net;\""], ttl = "1" },
  }
}

data "sops_file" "this" {
  source_file = "secrets.sops.yaml"
}

import {
  id = "74f896578568875d67af7c4fb1a0442d/4045190170969c124db3966024205f1c"
  to = module.dns_records.cloudflare_dns_record.cname["74f896578568875d67af7c4fb1a0442d_wg_CNAME"]
}
