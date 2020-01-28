
# unmanaged instance group

resource "google_compute_instance_group" "instance_grp_pfsense" {
  name      = "${var.vpc1.prefix}ig-asia-1"
  zone      = "${var.vpc1.region}-b"
  instances = [local.vpc1.pfsense.self_link]
}
