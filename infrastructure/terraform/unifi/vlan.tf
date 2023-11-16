resource "unifi_network" "management" {
  name    = "management"
  purpose = "vlan-only"

  vlan_id       = 30
  igmp_snooping = true
}

resource "unifi_network" "wireless" {
  name    = "wireless"
  purpose = "vlan-only"

  vlan_id       = 10
  igmp_snooping = true
}

resource "unifi_network" "guest" {
  name    = "guest"
  purpose = "vlan-only"

  vlan_id       = 5
  igmp_snooping = true
}

resource "unifi_network" "iot" {
  name    = "iot"
  purpose = "vlan-only"

  vlan_id       = 20
  igmp_snooping = true
}

resource "unifi_network" "video" {
  name    = "video"
  purpose = "vlan-only"

  vlan_id       = 8
  igmp_snooping = true
}

resource "unifi_network" "cilium" {
  name    = "cilium"
  purpose = "vlan-only"

  vlan_id       = 50
  igmp_snooping = true
}
