# provider
provider "google" {
  project     = "${var.project_name}"
  credentials = "${file("${var.credentials_file_path}")}"
  region  = "europe-west1"
}

terraform {
  backend "gcs" {
    bucket  = "tf-shk"
    prefix  = "states/hybrid-gcp-aws/gcp/eu-west1/"
    credentials ="/home/salawu/Terraform/credentials/gcp-credentials-tf.json"
  }
}

# remote state files for aws tunnel data
data "terraform_remote_state" "aws_eu_west1_vpc1_data" {
  backend = "gcs"
  config {
    bucket  = "tf-shk"
    prefix  = "states/hybrid-gcp-aws/aws/eu-west1/vpc1"
    credentials ="/home/salawu/Terraform/credentials/gcp-credentials-tf.json"
  }
}

# Retrieve vpn gateway external IP addresses
#--------------------------------------
data "google_compute_address" "gcp_eu_w1_vpn_gw1_ip" {
  name = "gcp-eu-w1-vpn-gw1-ip"
}

data "google_compute_address" "gcp_eu_w1_vpn_gw2_ip" {
  name = "gcp-eu-w1-vpn-gw2-ip"
}

# existing vpc data form gcp
data "google_compute_network" "vpc" {
  name  = "${var.name}-vpc"
}

# existing subnetwork data form gcp
data "google_compute_subnetwork" "eu_w1_subnet_10_10_10" {
  name   = "${var.name}-eu-w1-subnet-10-10-10"
}

data "google_compute_subnetwork" "eu_w1_subnet_10_10_11" {
  name   = "${var.name}-eu-w1-subnet-10-10-11"
}
