module "dns_records" {
  source = "./dns"
  providers = {
    cloudflare = cloudflare
  }

  zone = { id = data.cloudflare_zone.default.id, name = data.cloudflare_zone.default.name }

  a_records = {
    # make the root domain target self, allowing you to redirect it
    # see zone.tf redirect rule
    "garb.dev" = { ip = "192.0.2.1", ttl = "1", proxied = true }
  }

  cname_records = {
    "sig1._domainkey" = { cname = nonsensitive(local.secrets["DOMAIN_KEY_APPLE"]), ttl = "3600", proxied = false },
    "www"             = { cname = "garb.dev", ttl = "1", proxied = true }
    "wg"              = { cname = "ipv4.garb.dev", ttl = "1", proxied = false }
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
  to = module.dns_records.cloudflare_record.a["74f896578568875d67af7c4fb1a0442d_garb.dev_A"]
  id = "74f896578568875d67af7c4fb1a0442d/f4696ca25dbb29a840f0dad92a38a8e5"
}

import {
  to = module.dns_records.cloudflare_record.cname["74f896578568875d67af7c4fb1a0442d_wg_CNAME"]
  id = "74f896578568875d67af7c4fb1a0442d/9e3e64898f4a7bd00f4d406f0dac20fd"
}

import {
  to = module.dns_records.cloudflare_record.cname["74f896578568875d67af7c4fb1a0442d_www_CNAME"]
  id = "74f896578568875d67af7c4fb1a0442d/564781337a499754c39c8e724f3fd94a"
}

import {
  to = module.dns_records.cloudflare_record.mx["74f896578568875d67af7c4fb1a0442d_garb.dev_mx01.mail.icloud.com._MX"]
  id = "74f896578568875d67af7c4fb1a0442d/89257aaa5f1ef2fef2916260a8375d11"
}

import {
  to = module.dns_records.cloudflare_record.mx["74f896578568875d67af7c4fb1a0442d_garb.dev_mx02.mail.icloud.com._MX"]
  id = "74f896578568875d67af7c4fb1a0442d/fb1ac8ca896b70ffa54719aaf43c2d8e"
}

import {
  to = module.dns_records.cloudflare_record.txt["74f896578568875d67af7c4fb1a0442d__dmarc_0_TXT"]
  id = "74f896578568875d67af7c4fb1a0442d/66127e66d0f6ce1ee399434bbade6fa5"
}

import {
  to = module.dns_records.cloudflare_record.cname["74f896578568875d67af7c4fb1a0442d_sig1._domainkey_CNAME"]
  id = "74f896578568875d67af7c4fb1a0442d/c31eac35aa9bceef20383fa6e37789dc"
}

import {
  to = module.dns_records.cloudflare_record.txt["74f896578568875d67af7c4fb1a0442d_garb.dev_2_TXT"]
  id = "74f896578568875d67af7c4fb1a0442d/06a6179389169630556a688019090f0d"
}

import {
  to = module.dns_records.cloudflare_record.txt["74f896578568875d67af7c4fb1a0442d_garb.dev_1_TXT"]
  id = "74f896578568875d67af7c4fb1a0442d/ef1a249eecab814b5e9df471f8693820"
}

import {
  to = cloudflare_ruleset.this
  id = "zone/74f896578568875d67af7c4fb1a0442d/9e0f648710aa415c93eb9236d2db8d9a"
}
