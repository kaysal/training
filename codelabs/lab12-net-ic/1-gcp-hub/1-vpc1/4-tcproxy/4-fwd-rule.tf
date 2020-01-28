
# forwarding rule

resource "google_compute_global_forwarding_rule" "mqtt_fr" {
  name        = "mqtt-fr"
  target      = google_compute_target_tcp_proxy.tcp_proxy_mqtt.self_link
  ip_address  = local.mqtt_tcp_proxy_vip.address
  ip_protocol = "TCP"
  port_range  = "1883"
}
