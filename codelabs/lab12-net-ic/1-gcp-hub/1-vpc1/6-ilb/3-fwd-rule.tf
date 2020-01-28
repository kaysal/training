
# forwarding rule

resource "google_compute_forwarding_rule" "payment_fwd_rule" {
  provider              = google-beta
  name                  = "payment-fwd-rule"
  region                = var.hub.vpc1.us.region
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.payment_be_svc.self_link
  subnetwork            = local.subnet.us.payment.self_link
  ip_address            = var.hub.vpc1.us.ip.ilb
  ip_protocol           = "TCP"
  ports                 = ["80"]
  service_label         = "next19"
}
