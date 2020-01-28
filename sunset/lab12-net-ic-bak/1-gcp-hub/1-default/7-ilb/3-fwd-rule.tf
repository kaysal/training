
# forwarding rule

resource "google_compute_forwarding_rule" "payment_fwd_rule" {
  provider              = google-beta
  name                  = "payment-fwd-rule"
  region                = var.hub.default.us.region
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.payment_be_svc.self_link
  network               = local.default.self_link
  ip_address            = var.hub.default.us.ilb_vip
  ip_protocol           = "TCP"
  ports                 = ["80"]
  service_label         = "next19"
}
