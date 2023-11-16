resource "unifi_device" "us_16_xg" {
  mac  = "18:e8:29:20:c1:1f"
  name = "Berserk"

  allow_adoption    = true
  forget_on_destroy = true

  port_override {
    name   = "SFP+ Port 1"
    number = 1
  }
  port_override {
    name    = "Port 9 - SFP+"
    number  = 9
    op_mode = "switch"
  }
  port_override {
    aggregate_num_ports = 2
    name                = "Switch - Aggregate"
    number              = 11
    op_mode             = "aggregate"
  }
  port_override {
    name    = "Switch - Downlink"
    number  = 12
    op_mode = "switch"
  }
  port_override {
    name    = "Proxmox-2"
    number  = 14
    op_mode = "switch"
  }
  port_override {
    name    = "Switch - Downlink - Prx 2"
    number  = 15
    op_mode = "switch"
  }
  port_override {
    name    = "Port 16"
    number  = 16
    op_mode = "switch"
  }
}

resource "unifi_device" "us_enterprise_24_poe" {
  mac  = "d8:b3:70:67:f8:9e"
  name = "Leap"
  port_override {
    name    = "Port 10"
    number  = 10
    op_mode = "switch"
  }
  port_override {

    name    = "Port 11"
    number  = 11
    op_mode = "switch"
  }
  port_override {

    name    = "Port 19"
    number  = 19
    op_mode = "switch"
  }
  port_override {

    name    = "Port 2"
    number  = 2
    op_mode = "switch"
  }
  port_override {

    name    = "Port 20"
    number  = 20
    op_mode = "switch"
  }
  port_override {

    name    = "Port 21"
    number  = 21
    op_mode = "switch"
  }
  port_override {

    name    = "Port 23"
    number  = 23
    op_mode = "switch"
  }
  port_override {

    name    = "Port 24"
    number  = 24
    op_mode = "switch"
  }
  port_override {

    name    = "Port 26"
    number  = 26
    op_mode = "switch"
  }
  port_override {

    name    = "Port 3"
    number  = 3
    op_mode = "switch"
  }
  port_override {

    name    = "Port 4"
    number  = 4
    op_mode = "switch"
  }
  port_override {

    name    = "Port 5"
    number  = 5
    op_mode = "switch"
  }
  port_override {

    name    = "Port 6"
    number  = 6
    op_mode = "switch"
  }
  port_override {

    name    = "fluffy"
    number  = 14
    op_mode = "switch"
  }
  port_override {

    name    = "frenzy"
    number  = 13
    op_mode = "switch"
  }
  port_override {

    name    = "gpu"
    number  = 15
    op_mode = "switch"
  }
  port_override {

    name    = "marie office trunk"
    number  = 1
    op_mode = "switch"
  }
  port_override {

    name    = "whirlwind"
    number  = 12
    op_mode = "switch"
  }
  port_override {
    aggregate_num_ports = 2
    name                = "Port 25"
    number              = 25
    op_mode             = "aggregate"
  }
}

resource "unifi_device" "usw_flex_xg" {
  mac  = "24:5a:4c:1d:fd:c6"
  name = "Stun"
  port_override {

    name    = "Port 1"
    number  = 1
    op_mode = "switch"
  }
  port_override {

    name   = "Port 3"
    number = 3
  }
  port_override {

    name    = "Switch Uplink"
    number  = 2
    op_mode = "switch"
  }
}

resource "unifi_device" "u6_iw_downstairs" {
  mac  = "70:a7:41:e5:f3:f7"
  name = "Slam"

  port_override {
    name    = "Printer"
    number  = 1
    op_mode = "switch"
  }
}

resource "unifi_device" "u6_iw_upstairs" {
  mac  = "70:a7:41:e5:f3:17"
  name = "Bash"
  port_override {
    name    = "ps5"
    number  = 1
    op_mode = "switch"
  }
}

resource "unifi_device" "u6_mesh" {
  mac  = "d0:21:f9:ff:03:cc"
  name = "Warcry"
}
