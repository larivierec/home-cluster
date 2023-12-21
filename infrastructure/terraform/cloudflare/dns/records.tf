locals {
  a_records = flatten([
    for record, record_data in var.a_records : {
      record  = record
      proxied = record_data.proxied
      ip      = record_data.ip
      ttl     = record_data.ttl
    }
  ])

  cname_records = flatten([
    for record, record_data in var.cname_records : {
      record  = record
      proxied = record_data.proxied
      cname   = record_data.cname
      ttl     = record_data.ttl
    }
  ])

  mx_records = flatten([
    for record, record_data in var.mx_records : [
      for mx_record in record_data.records : {
        record   = record
        ttl      = record_data.ttl
        priority = mx_record.priority
        address  = mx_record.address
      }
    ]
  ])

  txt_records = flatten([
    for record, record_data in var.txt_records : [
      for txt_record in record_data.records : {
        record = record
        ttl    = record_data.ttl
        data   = txt_record
      }
    ]
  ])

  comment = "Created via Terraform"
}

resource "cloudflare_record" "a" {
  for_each = { for data in local.a_records : "${var.zone.id}_${data.record}_A" => data }
  zone_id  = var.zone.id
  name     = each.value.record
  type     = "A"
  ttl      = each.value.ttl
  proxied  = each.value.proxied
  value    = each.value.ip
  comment  = local.comment
}

resource "cloudflare_record" "cname" {
  for_each = { for data in local.cname_records : "${var.zone.id}_${data.record}_CNAME" => data }
  zone_id  = var.zone.id
  name     = each.value.record
  type     = "CNAME"
  ttl      = each.value.ttl
  proxied  = each.value.proxied
  value    = each.value.cname
  comment  = local.comment
}

resource "cloudflare_record" "mx" {
  for_each = { for data in local.mx_records : "${var.zone.id}_${data.record}_${data.address}_MX" => data }
  zone_id  = var.zone.id
  name     = each.value.record
  type     = "MX"
  ttl      = each.value.ttl
  priority = each.value.priority
  value    = each.value.address
  comment  = local.comment
}

resource "cloudflare_record" "txt" {
  for_each = { for idx, data in local.txt_records : "${var.zone.id}_${data.record}_${idx}_TXT" => data }
  zone_id  = var.zone.id
  name     = each.value.record
  type     = "TXT"
  ttl      = each.value.ttl
  value    = each.value.data
  comment  = local.comment
}
