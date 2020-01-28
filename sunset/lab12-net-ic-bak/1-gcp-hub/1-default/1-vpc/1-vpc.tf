
# gcp
#------------------------------------

# network

resource "google_compute_network" "default" {
  name                    = "default-vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = true
}

# gclb vip

resource "google_compute_global_address" "gclb_vip" {
  name        = "gclb-vip"
  description = "static ipv4 address for gclb frontend"
}

# gclb vip standard tier

resource "google_compute_address" "gclb_vip_standard" {
  name         = "gclb-vip-standard"
  description  = "static ipv4 address for gclb frontend"
  region       = var.hub.default.us.region
  network_tier = "STANDARD"
}

# mqtt tcp proxy ip

resource "google_compute_global_address" "mqtt_tcp_proxy_vip" {
  name        = "mqtt-tcp-proxy-vip"
  description = "static global ip for tcp proxy"
}
