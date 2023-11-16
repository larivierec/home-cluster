data "unifi_ap_group" "default" {}

data "unifi_user_group" "default" {}

resource "unifi_wlan" "mgmt" {
  name              = "Beer Crew - Management"
  security          = "wpapsk"
  passphrase        = lookup(local.secrets, "tf-unifi-wlan-management").text
  network_id        = unifi_network.management.id
  ap_group_ids      = [data.unifi_ap_group.default.id]
  user_group_id     = data.unifi_user_group.default.id
  hide_ssid         = true
  pmf_mode          = "optional"
  wpa3_support      = true
  wpa3_transition   = true
  bss_transition    = true
  multicast_enhance = true
}

resource "unifi_wlan" "guest" {
  name              = "Beer Crew - Guest"
  security          = "wpapsk"
  passphrase        = lookup(local.secrets, "tf-unifi-wlan-guest").text
  network_id        = unifi_network.guest.id
  ap_group_ids      = [data.unifi_ap_group.default.id]
  user_group_id     = data.unifi_user_group.default.id
  l2_isolation      = true
  pmf_mode          = "optional"
  wpa3_support      = true
  wpa3_transition   = true
  bss_transition    = true
  multicast_enhance = true
}

resource "unifi_wlan" "iot" {
  name              = "Beer Crew - IoT"
  security          = "wpapsk"
  passphrase        = lookup(local.secrets, "tf-unifi-wlan-iot").text
  network_id        = unifi_network.iot.id
  ap_group_ids      = [data.unifi_ap_group.default.id]
  user_group_id     = data.unifi_user_group.default.id
  pmf_mode          = "optional"
  wpa3_support      = true
  wpa3_transition   = true
  bss_transition    = true
  multicast_enhance = true
}

resource "unifi_wlan" "wireless" {
  name                 = "Beer Crew"
  security             = "wpapsk"
  passphrase           = lookup(local.secrets, "tf-unifi-wlan-wireless").text
  network_id           = unifi_network.wireless.id
  ap_group_ids         = [data.unifi_ap_group.default.id]
  user_group_id        = data.unifi_user_group.default.id
  pmf_mode             = "optional"
  wpa3_support         = true
  wpa3_transition      = true
  uapsd                = true
  bss_transition       = true
  fast_roaming_enabled = true
  multicast_enhance    = true
}
