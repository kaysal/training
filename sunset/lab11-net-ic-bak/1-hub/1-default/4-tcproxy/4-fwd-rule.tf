# forwarding rule
resource "google_compute_global_forwarding_rule" "fwd_rule_smtp" {
  name        = "fwd-rule-smtp"
  target      = google_compute_target_tcp_proxy.tcp_proxy_smtp.self_link
  ip_address  = local.smtp_tcp_proxy_vip.address
  ip_protocol = "TCP"
  port_range  = "25"
}
