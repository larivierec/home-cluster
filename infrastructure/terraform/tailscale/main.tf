data "sops_file" "this" {
  source_file = "secrets.sops.yaml"
}

data "tailscale_device" "k8s-gateway" {
  hostname = "tailscale-k8s-gateway"
  wait_for = "60s"
}

data "tailscale_device" "apple-tv" {
  hostname = "apple-tv"
  wait_for = "30s"
}

resource "tailscale_device_key" "apple-tv" {
  device_id           = data.tailscale_device.apple-tv.id
  key_expiry_disabled = true
}

resource "tailscale_dns_preferences" "magic_dns" {
  magic_dns = true
}

resource "tailscale_dns_nameservers" "home-ns" {
  nameservers = [
    "192.168.1.2",
    "192.168.1.1"
  ]
}

resource "tailscale_dns_search_paths" "search" {
  search_paths = [
    "home"
  ]
}

resource "tailscale_device_tags" "apple-tv" {
  device_id = data.tailscale_device.apple-tv.id
  tags      = ["tag:node"]
}

resource "tailscale_device_subnet_routes" "routes" {
  for_each = toset(
    [
      data.tailscale_device.apple-tv.id
    ]
  )
  device_id = each.key
  routes = sort([
    "192.168.0.0/16",
    # Or configure as an exit node
    "0.0.0.0/0",
    "::/0"
  ])
  lifecycle {
    ignore_changes = [device_id]
  }
}

resource "tailscale_acl" "account_acl" {
  acl = jsonencode({
    "randomizeClientPort" : true,
    "acls" : [
      { "action" : "accept", "src" : ["*"], "dst" : ["*:*"] },
    ],
    "autoApprovers" : {
      "routes" : {
        "192.168.0.0/16" : [local.tailscale_secret["email"], "tag:cluster-node", "tag:node"],
      },
      "exitNode" : ["tag:node", "tag:cluster-node"],
    },

    "ssh" : [
      {
        "action" : "check",
        "src" : ["autogroup:member"],
        "dst" : ["autogroup:self"],
        "users" : ["autogroup:nonroot", "root"],
      },
    ],

    "tagOwners" : {
      "tag:node" : [local.tailscale_secret["email"]],
      "tag:cluster-node" : [local.tailscale_secret["email"]],
    },
  })
}
