# http proxy frontend

resource "google_compute_target_http_proxy" "http_proxy" {
  project = var.project_id_vpc1
  name    = "${var.vpc1.prefix}http-proxy"
  url_map = google_compute_url_map.url_map.self_link
}
