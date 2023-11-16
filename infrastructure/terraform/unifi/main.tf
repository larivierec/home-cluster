resource "unifi_device" "us_16_xg" {
  mac = "18:e8:29:20:c1:1f"
  name = "Berserk"

  allow_adoption    = true
  forget_on_destroy = true

  port_override {
    name                = "SFP+ Port 1"
    number              = 1
  }
  port_override {
    name                = "Port 9 - SFP+"
    number              = 9
    op_mode             = "switch"
  }
  port_override {
    aggregate_num_ports = 2
    name                = "Switch - Aggregate"
    number              = 11
    op_mode             = "aggregate"
  }
  port_override {
    name                = "Switch - Downlink"
    number              = 12
    op_mode             = "switch"
  }
  port_override {
    name                = "Proxmox-2"
    number              = 14
    op_mode             = "switch"
  }
  port_override {
    name                = "Switch - Downlink - Prx 2"
    number              = 15
    op_mode             = "switch"
  }
  port_override {
    name                = "Port 16"
    number              = 16
    op_mode             = "switch"
  }
}

# resource "unifi_device" "us_enterprise_24_poe" {
#   mac = "d8:b3:70:67:f8:9e"
#   name = "Leap"
# }

resource "unifi_device" "usw_flex_xg" {
  mac = "24:5a:4c:1d:fd:c6"
  name = "Stun"
}

