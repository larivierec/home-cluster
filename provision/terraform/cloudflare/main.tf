module "dns_records" {
  source = "./dns"
  providers = {
    cloudflare = cloudflare
  }

  zone = { id = data.cloudflare_zone.default.id, name = data.cloudflare_zone.default.name }

  a_records = {
    nonsensitive(data.sops_file.cloudflare_secrets.data["SECRET_DOMAIN"]) = { ip = "${data.http.ip_address.response_body}", ttl = "1", proxied = true }
  }

  cname_records = {
    "wireguard" = { cname = nonsensitive(data.sops_file.cloudflare_secrets.data["SECRET_DOMAIN"]), ttl = "1", proxied = false},
    "protonmail._domainkey" = { cname = nonsensitive(data.sops_file.cloudflare_secrets.data["SECRET_MX_DOMAIN_KEY_1"]), ttl = "1", proxied = false},
    "protonmail2._domainkey" = { cname = nonsensitive(data.sops_file.cloudflare_secrets.data["SECRET_MX_DOMAIN_KEY_2"]), ttl = "1", proxied = false},
    "protonmail3._domainkey" = { cname = nonsensitive(data.sops_file.cloudflare_secrets.data["SECRET_MX_DOMAIN_KEY_3"]), ttl = "1", proxied = false},
  }

  mx_records = {
    nonsensitive(data.sops_file.cloudflare_secrets.data["SECRET_DOMAIN"]) = {
      ttl = "300" 
      records = [
          { priority = 10, address = nonsensitive(data.sops_file.cloudflare_secrets.data["SECRET_MX_DOMAIN_MX_1"]) },
          { priority = 20, address = nonsensitive(data.sops_file.cloudflare_secrets.data["SECRET_MX_DOMAIN_MX_2"]) },
        ]
    }
  }

  txt_records = {
    nonsensitive(data.sops_file.cloudflare_secrets.data["SECRET_DOMAIN"]) = { records = [
      nonsensitive(data.sops_file.cloudflare_secrets.data["SECRET_MX_DOMAIN_TXT_1"]),
      nonsensitive(data.sops_file.cloudflare_secrets.data["SECRET_MX_DOMAIN_DATA"]),
    ], ttl = "300"},
    "_dmarc" = { records = [nonsensitive(data.sops_file.cloudflare_secrets.data["SECRET_MX_DOMAIN_DMARC"])], ttl = "1"},
  }
}

data "http" "ip_address" {
  url = "https://api64.ipify.org"
}

data "sops_file" "cloudflare_secrets" {
  source_file = "secrets.sops.yaml"
}
