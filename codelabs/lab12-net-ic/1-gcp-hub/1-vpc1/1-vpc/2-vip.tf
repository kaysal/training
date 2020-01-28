
# gclb vip

resource "google_compute_global_address" "gclb_vip" {
  name        = "gclb-vip"
  description = "static ipv4 address for gclb frontend"
}

# gclb vip standard tier

resource "google_compute_address" "gclb_standard_vip" {
  name         = "gclb-standard-vip"
  description  = "static ipv4 address for gclb frontend"
  region       = var.hub.vpc1.us.region
  network_tier = "STANDARD"
}

# mqtt tcp proxy vip

resource "google_compute_global_address" "mqtt_tcp_proxy_vip" {
  name        = "mqtt-tcp-proxy-vip"
  description = "static global ip for tcp proxy"
}
