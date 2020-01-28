
# networks
#------------------------------------

resource "google_compute_network" "default" {
  name                    = "default"
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

# gclb vip premium tier

resource "google_compute_global_address" "gclb_vip_premium" {
  name        = "gclb-vip-premium"
  description = "static ipv4 address for gclb frontend"
}

# smtp tcp proxy ip

resource "google_compute_global_address" "smtp_tcp_proxy_vip" {
  name        = "smtp-tcp-proxy-vip"
  description = "static global ip for tcp proxy"
}

# probe-us nat ip

resource "google_compute_address" "probe_us_nat_ip" {
  name        = "probe-us-nat-ip"
  description = "nat ip for probe-us vm"
  region      = var.hub.default.us.region
}
