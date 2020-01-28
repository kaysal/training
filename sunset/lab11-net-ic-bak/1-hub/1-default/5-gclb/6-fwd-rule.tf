
# forwarding rule - shopping site

resource "google_compute_global_forwarding_rule" "shopping_site_fr" {
  name        = "shopping-site-fr"
  target      = google_compute_target_http_proxy.http_proxy.self_link
  ip_address  = local.gclb_vip.address
  ip_protocol = "TCP"
  port_range  = "80"
}

# forwarding rule - standard tier

resource "google_compute_forwarding_rule" "standard_tier_fr" {
  name         = "standard-tier-fr"
  target       = google_compute_target_http_proxy.http_proxy_standard_tier.self_link
  ip_address   = local.gclb_vip_standard.address
  network_tier = "STANDARD"
  region       = var.hub.default.us.region
  ip_protocol  = "TCP"
  port_range   = "80"
}

# forwarding rule - premium tier

resource "google_compute_global_forwarding_rule" "premium_tier_fr" {
  name        = "premium-tier-fr"
  target      = google_compute_target_http_proxy.http_proxy_premium_tier.self_link
  ip_address  = local.gclb_vip_premium.address
  ip_protocol = "TCP"
  port_range  = "80"
}
