
# http proxy frontend

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.shopping_site.self_link
}

# http proxy frontend - standard tier

resource "google_compute_target_http_proxy" "http_proxy_standard_tier" {
  name    = "http-proxy-standard-tier"
  url_map = google_compute_url_map.standard_tier.self_link
}

# http proxy frontend - premium tier

resource "google_compute_target_http_proxy" "http_proxy_premium_tier" {
  name    = "http-proxy-premium-tier"
  url_map = google_compute_url_map.premium_tier.self_link
}
