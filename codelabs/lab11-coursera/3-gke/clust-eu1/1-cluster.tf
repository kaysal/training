locals {
  project  = var.project_id
  location = var.orange.eu1.region
}

# cluster

module "gke" {

  source  = "../../../../../tf_modules/gcp/gke"
  project = local.project

  name           = "clust-eu1"
  description    = "NEG, Private, NetPolicy"
  location       = local.location
  node_locations = ["${local.location}-c"]
  network        = local.vpc.self_link
  subnetwork     = local.eu1_gke_cidr.self_link

  disable_public_endpoint   = false
  enable_private_nodes      = true
  master_ipv4_cidr_block    = var.orange.eu1.cidr.gke.api
  pods_range_name           = "pod-range"
  services_range_name       = "svc-range"
  default_max_pods_per_node = 16
  min_master_version        = "1.15.4-gke.22"

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  enable_binary_authorization = false
  enable_istio_config         = false

  master_authorized_networks_config = [
    {
      cidr_blocks = [
        {
          cidr_block   = "0.0.0.0/0"
          display_name = "all-external"
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
  provider           = google-beta
  name               = "node-pool"
  location           = local.location
  cluster            = module.gke.name
  initial_node_count = 2

  autoscaling {
    min_node_count = 2
    max_node_count = 4
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    image_type      = "COS"
    machine_type    = "n1-standard-1"
    disk_size_gb    = "30"
    disk_type       = "pd-standard"
    preemptible     = false
    service_account = local.svc_account.email

    labels = {
      private = "true"
    }

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

/*
resource "google_container_node_pool" "node_pool_preempt" {
  provider           = google-beta
  name               = "node-pool-preempt"
  location           = local.location
  cluster            = module.gke.name
  initial_node_count = 2

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    image_type      = "COS"
    machine_type    = "n1-standard-1"
    disk_size_gb    = "30"
    disk_type       = "pd-standard"
    preemptible     = "true"
    service_account = local.svc_account.email

    labels = {
      private = "true"
      temp    = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}*/
