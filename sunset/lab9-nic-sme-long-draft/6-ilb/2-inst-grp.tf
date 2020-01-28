
# unmanaged instance group

resource "google_compute_instance_group" "asia_ig_b" {
  project   = var.project_id_spoke2
  name      = "${var.spoke2.prefix}asia-ig-b"
  zone      = "${var.spoke2.asia.region}-b"
  instances = [local.spoke2.asia_vm1.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}

resource "google_compute_instance_group" "asia_ig_c" {
  project   = var.project_id_spoke2
  name      = "${var.spoke2.prefix}asia-ig-c"
  zone      = "${var.spoke2.asia.region}-c"
  instances = [local.spoke2.asia_vm2.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}
