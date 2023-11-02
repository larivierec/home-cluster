data "sops_file" "this" {
  source_file = "secrets.sops.yaml"
}

data "tailscale_device" "router" {
  provider = tailscale
  name = "opnsense.${lookup(local.secrets, "tailscale-tailnet").text}"
}

data "tailscale_device" "k8s-gateway" {
  name = "tailscale-k8s-gateway.${lookup(local.secrets, "tailscale-tailnet").text}"
}

resource "tailscale_device_key" "router" {
  device_id           = data.tailscale_device.router.id
  key_expiry_disabled = true
}

resource "tailscale_device_key" "k8s-gateway" {
  device_id           = data.tailscale_device.k8s-gateway.id
  key_expiry_disabled = true
}

resource "tailscale_dns_preferences" "magic_dns" {
  magic_dns = true
}

resource "tailscale_dns_nameservers" "home-ns" {
  nameservers = [
    "192.168.50.7",
    "192.168.50.1"
  ]
}

resource "tailscale_dns_search_paths" "search" {
  search_paths = [
    "home"
  ]
}

resource "tailscale_device_tags" "router" {
  device_id = data.tailscale_device.router.id
  tags = ["tag:router"]
}

resource "tailscale_device_tags" "k8s-gateway" {
  device_id = data.tailscale_device.k8s-gateway.id
  tags = ["tag:k8s"]
}

resource "tailscale_device_subnet_routes" "routes" {
  for_each = toset([data.tailscale_device.router.id, data.tailscale_device.k8s-gateway.id])
  device_id = each.key
  routes = [
    "192.168.0.0/16",
  ]
}

resource "tailscale_acl" "account_acl" {
  acl = jsonencode({
    // Declare static groups of users. Use autogroups for all users or users with a specific role.
    // "groups": {
    //  	"group:example": ["alice@example.com", "bob@example.com"],
    // },

    // Define the tags which can be applied to devices and by which users.
    // "tagOwners": {
    //  	"tag:example": ["autogroup:admin"],
    // },
    "randomizeClientPort": true,
    // Define access control lists for users, groups, autogroups, tags,
    // Tailscale IP addresses, and subnet ranges.
    "acls": [
      // Allow all connections.
      // Comment this section out if you want to define specific restrictions.
      {"action": "accept", "src": ["*"], "dst": ["*:*"]},
    ],
    "autoApprovers": {
      // Alice can create subnet routers advertising routes in 10.0.0.0/24 that are auto-approved
      "routes": {
        "192.168.0.0/16": [lookup(local.secrets, "tailscale-email").text, "tag:k8s", "tag:k8s-operator", "tag:router"],
      },
      // A device tagged security can advertise exit nodes that are auto-approved
      "exitNode": ["tag:router", "tag:k8s", "tag:k8s-operator"],
    },

    // Define users and devices that can use Tailscale SSH.
    "ssh": [
      // Allow all users to SSH into their own devices in check mode.
      // Comment this section out if you want to define specific restrictions.
      {
        "action": "check",
        "src":    ["autogroup:member"],
        "dst":    ["autogroup:self"],
        "users":  ["autogroup:nonroot", "root"],
      },
    ],

    // Test access rules every time they're saved.
    // "tests": [
    //  	{
    //  		"src": "alice@example.com",
    //  		"accept": ["tag:example"],
    //  		"deny": ["100.101.102.103:443"],
    //  	},
    // ],
    "tagOwners": {
      "tag:router":       [lookup(local.secrets, "tailscale-email").text],
      "tag:k8s":          [lookup(local.secrets, "tailscale-email").text],
      "tag:k8s-operator": [lookup(local.secrets, "tailscale-email").text],
    },
  })
}