variable "project_id" {
  description = "Cluster project."
}

variable "name" {
  description = "Cluster name."
}

variable "location" {
  description = "Cluster region."
}

variable "remove_default_node_pool" {
  description = "remove default node pool"
  default     = false
}

variable "network" {
  description = "Cluster network."
}

variable "subnetwork" {
  description = "Cluster subnetwork."
}

variable "pods_range_name" {
  description = "Name of the alias IP range for pods."
}

variable "services_range_name" {
  description = "Name of the alias IP range for services."
}

variable "min_master_version" {
  description = "Minimum version for master."
  default     = "1.10.5-gke.3"
}

variable "logging_service" {
  description = "logging service"
  default     = "logging.googleapis.com/kubernetes"
}

variable "monitoring_service" {
  description = "monitoring service"
  default     = "monitoring.googleapis.com/kubernetes"
}

variable "cluster_labels" {
  type        = "map"
  description = "Labels to be attached to the cluster."

  default = {
    component = "gke"
  }
}

variable "node_labels" {
  type        = "map"
  description = "Labels to be attached to the nodes."

  default = {
    component = "gke"
  }
}

# node configuration attributes here
# https://www.terraform.io/docs/providers/google/r/container_cluster.html#disk_size_gb

variable "service_account" {
  description = "The service account to use for the default nodes in the cluster."
  default     = "default"
}

variable "oauth_scopes" {
  description = "Scopes for the nodes service account."
  type        = "list"

  default = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
  ]
}

# Changing network tags recreates the cluster!
variable "network_tags" {
  type        = "list"
  description = "Network tags to be attached to the cluster VMs, for firewall rules."
  default     = []
}

/* node_taints = [{
  key    = "taints.xxx.com_node-allocation"
  value  = "default-nodepool"
  effect = "PREFER_NO_SCHEDULE"
}] */
variable "node_taints" {
  type        = "list"
  description = "Taints applied to default nodes. List of maps."
  default     = []
}

variable "default_max_pods_per_node" {
  description = "number of pods per node"
  default     = 16
}

variable "enable_binary_authorization" {
  description = "enable binary authorization"
  default     = false
}

variable "machine_type" {
  description = "Node machine type"
  default     = "n1-standard-1"
}

variable "network_policy_enabled" {
  description = "network policy for the cluster"
  default     = false
}

variable "network_policy_config_disabled" {
  description = "network policy addon for the master"
  default     = true
}

variable "kubernetes_dashboard_disabled" {
  description = "kubernetes Dashboard is enabled for this cluster"
  default     = true
}

variable "istio_config_disabled" {
  description = "status of the Istio addon"
  default     = true
}

variable "node_metadata" {
  description = "how to expose node metadata to pods"
  default     = "SECURE"
}

variable "enable_private_endpoint" {
  description = "enable private endpoint"
  default     = false
}

variable "enable_private_nodes" {
  description = "enable private nodes"
  default     = true
}

variable "master_ipv4_cidr_block" {
  description = "enable private nodes"
}

variable "node_count" {
  description = "node count"
  default     = 1
}

variable "master_authorized_networks_config" {
  type        = "list"
  description = "master authorized networks"

  default  = [
    {
      cidr_blocks = [
        {
          cidr_block   = "0.0.0.0/0"
          display_name = "all-external"
        },
      ]
    }
  ]
}
