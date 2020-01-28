
resource "google_compute_route" "east_default" {
  provider         = google-beta
  name             = "${var.east.prefix}default"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.east_vpc.self_link
  next_hop_gateway = "global/gateways/default-internet-gateway"
  priority         = 990
}
