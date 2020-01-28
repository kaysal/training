locals {
  project  = var.project_id_svc
  location = var.svc.us1.region
}

# cluster

module "gke" {

  source  = "../../../../../tf_modules/gcp/gke"
  project = local.project

  name        = "clust-us1"
  description = "NEG, Private, NetPolicy"
  location    = local.location
  network     = local.svc.vpc.self_link
  subnetwork  = local.svc.us1_gke_cidr.self_link

  disable_public_endpoint   = false
  enable_private_nodes      = true
  master_ipv4_cidr_block    = "172.16.0.48/28"
  pods_range_name           = "pod-range"
  services_range_name       = "svc-range"
  default_max_pods_per_node = 16
  min_master_version        = "1.13.11-gke.14"

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  enable_binary_authorization = false
  enable_istio_config         = false

  master_authorized_networks_config = [
    {
      cidr_blocks = [
        {
          cidr_block   = "0.0.0.0/0"
          display_name = "all-ext-testing"
        },
      ]
    },
  ]

  cluster_labels = {
    component = "gke"
  }
}

# node pool

resource "google_container_node_pool" "node_pool" {
  provider = google-beta

  name     = "node-pool"
  project  = local.project
  location = local.location
  cluster  = module.gke.name

  initial_node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    image_type   = "COS"
    machine_type = "n1-standard-2"

    labels = {
      private = true
    }

    #tags = []

    disk_size_gb = "30"
    disk_type    = "pd-standard"
    preemptible  = false

    #service_account = local.service_account

    workload_metadata_config {
      node_metadata = "EXPOSE"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}
