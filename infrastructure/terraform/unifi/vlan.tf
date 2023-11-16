resource "unifi_network" "management" {
  name    = "management"
  purpose = "vlan-only"

  vlan_id      = 30
}

resource "unifi_network" "wireless" {
  name    = "wireless"
  purpose = "vlan-only"

  vlan_id      = 10
}

resource "unifi_network" "guest" {
  name    = "guest"
  purpose = "vlan-only"

  vlan_id      = 5
}

resource "unifi_network" "iot" {
  name    = "iot"
  purpose = "vlan-only"

  vlan_id      = 20
}

resource "unifi_network" "video" {
  name    = "video"
  purpose = "vlan-only"

  vlan_id      = 8
}

resource "unifi_network" "cilium" {
  name    = "cilium"
  purpose = "vlan-only"

  vlan_id      = 50
}
