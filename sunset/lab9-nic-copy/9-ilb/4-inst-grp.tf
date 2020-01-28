
# unmanaged instance group

resource "google_compute_instance_group" "instance_grp1" {
  name      = "${var.spoke2.prefix}ig1"
  zone      = "${var.spoke2.region}-b"
  instances = [google_compute_instance.ilb_vm1.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}

resource "google_compute_instance_group" "instance_grp2" {
  name      = "${var.spoke2.prefix}ig2"
  zone      = "${var.spoke2.region}-c"
  instances = [google_compute_instance.ilb_vm2.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}
