
# untrust
#--------------------------------


resource "google_compute_route" "nva_untrust_east1" {
  provider     = google-beta
  name         = "${var.untrust.prefix}nva-untrust-east1"
  dest_range   = var.east.ilb_east1
  network      = google_compute_network.untrust_vpc.self_link
  next_hop_ilb = google_compute_forwarding_rule.nva_fr_east80.self_link
  priority     = 1000
}

resource "google_compute_route" "nva_untrust_east2" {
  provider     = google-beta
  name         = "${var.untrust.prefix}nva-untrust-east2"
  dest_range   = var.east.ilb_east2
  network      = google_compute_network.untrust_vpc.self_link
  next_hop_ilb = google_compute_forwarding_rule.nva_fr_east8080.self_link
  priority     = 1000
}
/*
# trust
#--------------------------------

resource "google_compute_route" "trust_route_b" {
  name                   = "${var.global.prefix}trust-route-b"
  dest_range             = "0.0.0.0/0"
  network                = google_compute_network.trust_vpc.self_link
  next_hop_instance_zone = "europe-west1-b"
  next_hop_instance      = "${google_compute_instance.pan_b.name}"
  priority               = 100
}

resource "google_compute_route" "trust_route_c" {
  name                   = "${var.global.prefix}trust-route-c"
  dest_range             = "0.0.0.0/0"
  network                = google_compute_network.trust_vpc.self_link
  next_hop_instance_zone = "europe-west1-c"
  next_hop_instance      = "${google_compute_instance.pan_c.name}"
  priority               = 100
}
*/
