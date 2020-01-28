# forwarding rule
resource "google_compute_global_forwarding_rule" "fwd_rule" {
  provider              = google-beta
  name                  = "fwd-rule"
  target                = google_compute_target_http_proxy.http_proxy.self_link
  load_balancing_scheme = "INTERNAL_SELF_MANAGED"
  network               = local.svc.vpc.self_link
  ip_address            = "10.10.10.10"
  port_range            = "80"
}
