
# unmanaged instance group

resource "google_compute_instance_group" "instance_grp_pfsense" {
  name      = "${var.trust.prefix}ig-asia-1"
  zone      = "${var.trust.region}-b"
  instances = [local.trust.pfsense.self_link]
}
