locals {
  a_records = flatten([
    for record, record_data in var.a_records : {
      record = record
      proxied = record_data.proxied
      ip = record_data.ip
      ttl = record_data.ttl
    }
  ])

  cname_records = flatten([
    for record, record_data in var.cname_records : {
      record = record
      proxied = record_data.proxied
      cname = record_data.cname
      ttl = record_data.ttl
    }
  ])

  mx_records = flatten([
    for record, mx_record_values in var.mx_records : {
      record = record
      ttl = mx_record_values.ttl
      records = [ for record in mx_record_values.records : "${record.priority} ${record.address}" ]
    }
  ])

  txt_records = flatten([
    for record, record_data in var.txt_records : {
      record = record
      ttl = record_data.ttl
    }
  ])
}

resource "cloudflare_record" "a" {
  for_each = { for subdomain in local.a_records : "${var.zone.id}_${subdomain.record}_A" => subdomain }
  zone_id = var.zone.id
  name = each.value.record
  type = "A"
  ttl = each.value.ttl
  proxied = each.value.proxied
  value = each.value.ip
}

resource "cloudflare_record" "cname" {
  for_each = { for subdomain in local.cname_records : "${var.zone.id}_${subdomain.record}_CNAME" => subdomain }
  zone_id = var.zone.id
  name = "${each.value.record}"
  type = "CNAME"
  ttl = each.value.ttl
  proxied = each.value.proxied
  value = each.value.cname
}

resource "cloudflare_record" "mx" {
  for_each = { for subdomain in local.a_records : "${var.zone.id}_${subdomain.record}_MX" => subdomain }
  zone_id = var.zone.id
  name = each.value.record
  type = "MX"
  ttl = each.value.ttl
  value = each.value.records
}

resource "cloudflare_record" "txt" {
  for_each = { for subdomain in local.a_records : "${var.zone.id}_${subdomain.record}_TXT" => subdomain }
  zone_id = var.zone.id
  name = each.value.record
  type = "TXT"
  ttl = each.value.ttl
  value = each.value.records
}