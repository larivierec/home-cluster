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
    "protonmail._domainkey"  = { cname = "protonmail.domainkey.dpdbrfrsi5bnnbgmawr3gmlslhcmbsffasbqutsxcwjg5hk7ows2a.domains.proton.ch.", ttl = "1", proxied = false },
    "protonmail2._domainkey" = { cname = "protonmail2.domainkey.dpdbrfrsi5bnnbgmawr3gmlslhcmbsffasbqutsxcwjg5hk7ows2a.domains.proton.ch.", ttl = "1", proxied = false },
    "protonmail3._domainkey" = { cname = "protonmail3.domainkey.dpdbrfrsi5bnnbgmawr3gmlslhcmbsffasbqutsxcwjg5hk7ows2a.domains.proton.ch.", ttl = "1", proxied = false },
    "sig1._domainkey"        = { cname = nonsensitive(lookup(local.cloudflare_secrets, "DOMAIN_KEY_APPLE").text), ttl = "3600", proxied = false },
  }

  mx_records = {
    nonsensitive(lookup(local.cloudflare_secrets, "domain").text) = {
      ttl = "3600"
      records = [
        { priority = 20, address = "mail.protonmail.ch" },
        { priority = 30, address = "mailsec.protonmail.ch" },
        { priority = 10, address = "mx01.mail.icloud.com." },
        { priority = 10, address = "mx02.mail.icloud.com." },
      ]
    }
  }

  txt_records = {
    nonsensitive(lookup(local.cloudflare_secrets, "domain").text) = { records = [
      "protonmail-verification=527b517787bb4a14f0c9160b3355cfb95c1e790e",
      "apple-domain=dPAmcbw67V29ieeV",
      # "\"v=spf1 include:icloud.com ~all\"",
      "\"v=spf1 mx include:_spf.protonmail.ch include:icloud.com ~all\"",
    ], ttl = "3600" },
    "_dmarc" = { records = ["v=DMARC1; p=quarantine"], ttl = "1" },
  }
}

data "http" "ip_address" {
  url = "https://ddns.${lookup(local.cloudflare_secrets, "domain").text}/v1/get"
}

data "sops_file" "this" {
  source_file = "secrets.sops.yaml"
}
