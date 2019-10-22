# url map
resource "google_compute_url_map" "url_map" {
  project         = var.project_id_vpc1
  name            = "${var.vpc1.prefix}url-map"
  default_service = google_compute_backend_service.be_svc_web.self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.be_svc_web.self_link
  }
}
