
# unmanaged instance group

resource "google_compute_instance_group" "instance_grp_asia_1" {
  project   = var.project_id_spoke1
  name      = "${var.spoke2.prefix}ig-asia-1"
  zone      = "${var.spoke2.region_asia}-b"
  instances = [local.spoke2.vm_asia_1.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}

resource "google_compute_instance_group" "instance_grp_asia_2" {
  project   = var.project_id_spoke1
  name      = "${var.spoke2.prefix}ig-asia-2"
  zone      = "${var.spoke2.region_asia}-c"
  instances = [local.spoke2.vm_asia_2.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}
